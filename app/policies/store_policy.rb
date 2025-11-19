class StorePolicy < ApplicationPolicy
  def index?
    user.owner? || user.seller?
  end

  def show?
    (user.owner? && record.organization == user.organization) ||
    (user.seller? && record.sellers.include?(user))
  end

  def create?
    user.owner? && user.organization.present?
  end

   def new?
    create?
  end

  def update?
    (user.owner? && record.organization == user.organization) ||
    (user.seller? && record.sellers.include?(user))
  end

  def destroy?
    false
  end

class Scope < ApplicationPolicy::Scope
    def resolve
      if user.owner? && user.organization.present?
        scope.where(organization: user.organization)
      elsif user.seller?
        scope.joins(:store_assignments).where(store_assignments: { user_id: user.id })
      else
        scope.none
      end
    end
  end
end
