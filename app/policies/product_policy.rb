class ProductPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.owner?
        # Owners see products from stores in their organization
        scope.joins(store: :organization)
             .where(stores: { organization_id: user.organization_id })
      elsif user.seller?
        # Sellers see products only from stores they are assigned to
        scope.joins(:store)
             .where(stores: { id: user.stores.ids })
      else
        scope.none
      end
    end
  end

  # View permissions
  def show?
    allowed_to_manage_product?
  end

  # Form access (new)
  def new?
    allowed_to_manage_product_for_new?
  end

  # Create permissions
  def create?
    allowed_to_manage_product_for_new?
  end

  # Update permissions
  def update?
    allowed_to_manage_product?
  end

  # Delete permissions
  def destroy?
    allowed_to_manage_product?
  end

  private

  # Shared logic for all CRUD actions
  def allowed_to_manage_product?
    return false if record.store.nil?

    if user.owner?
      record.store.organization_id == user.organization_id
    elsif user.seller?
      user.stores.include?(record.store)
    else
      false
    end
  end

  # For `new?`, when `record.store` may still be nil
  def allowed_to_manage_product_for_new?
    # Owners and sellers can open the form, even if no store selected yet
    user.owner? || user.seller?
  end
end