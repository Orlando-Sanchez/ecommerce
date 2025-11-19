# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }, if: proc { current_user.seller? && current_user.organization.nil? || current_user.owner? }

  content title: proc { I18n.t("active_admin.dashboard") } do
    if current_user.owner? && current_user.organization.nil?
      panel "Organization" do
        div style: "text-align: center; margin: 20px;" do
          link_to "Create Your Organization", new_admin_organization_path, class: "button"
        end
      end
    end

    if current_user.seller? && current_user.organization.nil?
      panel "Your Products" do
        div style: "margin-bottom: 10px;" do
          span link_to("Create New Product", new_admin_product_path, class: "button")
        end

        if current_user.products.any?
          table_for current_user.products do
            column :name
            column :price
            column :quantity
            column :status
            column :created_at
            column "Actions" do |product|
              links = []
              links << link_to("Edit", edit_admin_product_path(product))
              links << link_to("Delete", admin_product_path(product),
                               method: :delete,
                               data: { confirm: "Are you sure you want to delete this product?" })
              safe_join(links, " | ")
            end
          end
        else
          para "You don't have any products yet."
        end
      end
    end
    if (current_user.owner? && current_user.organization.present?) ||
      (current_user.seller? && current_user.organization.present?)

      panel "Welcome" do
        para "Welcome back! You are logged in as a #{current_user.owner? ? 'Owner' : 'Seller'} in the organization #{current_user.organization.name}."
      end

    end
  end
end