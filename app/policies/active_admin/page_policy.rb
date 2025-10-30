module ActiveAdmin
  class PagePolicy < ::ApplicationPolicy
    def index?
      user&.seller? || false
    end

    def show?
      index?
    end
  end
end
