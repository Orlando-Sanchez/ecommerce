# frozen_string_literal: true

ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    if current_user.owner? && current_user.organization.nil?
      # Panel para mostrar botón de crear organización
      panel "Organization" do
        div style: "text-align: center; margin: 20px;" do
          link_to "Create Your Organization", new_admin_organization_path, class: "button"
        end
      end
    else
      # Mensaje de bienvenida normal
      div class: "blank_slate_container", id: "dashboard_default_message" do
        span class: "blank_slate" do
          span I18n.t("active_admin.dashboard_welcome.welcome")
          small I18n.t("active_admin.dashboard_welcome.call_to_action")
        end
      end
    end
    # Here is an example of a simple dashboard with columns and panels.
    #
    # columns do
    #   column do
    #     panel "Recent Posts" do
    #       ul do
    #         Post.recent(5).map do |post|
    #           li link_to(post.title, admin_post_path(post))
    #         end
    #       end
    #     end
    #   end

    #   column do
    #     panel "Info" do
    #       para "Welcome to ActiveAdmin."
    #     end
    #   end
    # end
  end # content
end
