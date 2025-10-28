module ActiveAdmin
  class PagePolicy < ::ApplicationPolicy
    def index?
      user&.seller?
    end

    def show?
      index?
    end
  end
end