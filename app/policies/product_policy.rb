class ProductPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.owner?
        scope.joins(:store).where(stores: { organization_id: user.organization_id })
      elsif user.seller?
        scope.left_outer_joins(:store)
             .where("products.user_id = :user_id OR stores.id IN (:store_ids)",
                    user_id: user.id, store_ids: user.stores.ids)
      else
        scope.none
      end
    end
  end

  def show?
    allowed_to_manage_product?
  end

  def new?
    allowed_to_manage_product_for_new?
  end

  def create?
    allowed_to_manage_product_for_new?
  end

  def edit?
    allowed_to_manage_product?
  end

  def update?
    allowed_to_manage_product?
  end

  def destroy?
    allowed_to_manage_product?
  end

  private

  def allowed_to_manage_product?
    return true if user.admin?

    if user.owner?
      record.store.present? && record.store.organization_id == user.organization_id
    elsif user.seller?
      record.user_id == user.id || (record.store.present? && user.stores.include?(record.store))
    else
      false
    end
  end

  def allowed_to_manage_product_for_new?
    user.owner? || user.seller?
  end
end