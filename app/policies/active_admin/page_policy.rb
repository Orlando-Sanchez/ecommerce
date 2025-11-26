module ActiveAdmin
  class PagePolicy < ::ApplicationPolicy
    def index?
      user&.seller? || user&.owner? || false
    end

    def show?
      index?
    end
  end
end
