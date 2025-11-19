class UserPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.owner?
        scope.joins(:user_types).where(user_types: { name: "Seller" }, organization_id: user.organization_id)
      else
        scope.none
      end
    end
  end

  def index?
    user.owner?
  end

  def invite?
    user.owner?
  end

  def create_invitation?
    user.owner?
  end

  def destroy?
    user.owner?
  end
end