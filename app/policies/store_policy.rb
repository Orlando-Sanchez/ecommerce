class StorePolicy < ApplicationPolicy
  def index?
    (user.owner? && user.organization.present?) ||
    (user.seller? && user.organization.present?)
  end

  def show?
    return false if user.organization.nil?

    return true if user.owner? && record.organization == user.organization

    return true if user.seller? && record.sellers.include?(user)

    false
  end

  def create?
    user.owner? && user.organization.present?
  end

  def new?
    create?
  end

  def update?
    user.owner? && record.organization == user.organization
  end

  def destroy?
    false
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.owner? && user.organization.present?
        scope.where(organization: user.organization)

      elsif user.seller? && user.organization.present?
        scope.joins(:store_assignments)
             .where(store_assignments: { user_id: user.id })

      else
        scope.none
      end
    end
  end
end
