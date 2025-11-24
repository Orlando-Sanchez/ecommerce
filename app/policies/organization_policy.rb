class OrganizationPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.owner? && user.organization.present?
        scope.where(id: user.organization_id)
      else
        scope.none
      end
    end

    private

    attr_reader :user, :scope
  end

  def show?
    return false unless user&.owner?

    user.organization.present? && record.id == user.organization_id
  end

  def index?
    user.present?
  end

  def edit?
    show?
  end

  def update?
    show?
  end

  def new?
    create?
  end

  def create?
    user.owner? && user.organization.nil?
  end

  def destroy?
    false
  end
end