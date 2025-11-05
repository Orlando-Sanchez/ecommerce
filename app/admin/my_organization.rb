ActiveAdmin.register_page "My Organization" do
  menu label: "Organization", priority: 2, if: proc { current_user.owner? }

  controller do
    def index
      org = current_user.organization

      if org.present?
        redirect_to admin_organization_path(org)
      else
        redirect_to admin_root_path, alert: "You don't belong to any organization."
      end
    end
  end
end