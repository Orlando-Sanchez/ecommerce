ActiveAdmin.register Organization do
  menu false

  breadcrumb do
    []
  end

  config.filters = false

  actions :all, except: [:destroy]

  controller do
    include Pundit::Authorization

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    def user_not_authorized
      redirect_to admin_root_path, alert: "You are not authorized to view this organization."
    end

    def scoped_collection
      if current_user.owner?
        super.where(id: current_user.organization_id)
      else
        super.none
      end
    end

    def new
      authorize Organization
      if current_user.organization.present?
        redirect_to edit_admin_organization_path(current_user.organization),
                    alert: "You already belong to an organization."
      else
        super
      end
    end

    def create
      @organization = Organization.new(permitted_params[:organization])
      authorize @organization

      if @organization.save
        current_user.update!(organization: @organization)
        redirect_to edit_admin_organization_path(@organization),
                    notice: "Organization created correctly."
      else
        render :new
      end
    end

    def edit
      @organization = Organization.find(params[:id])

      if current_user.owner? && (@organization.id != current_user.organization_id)
        if current_user.organization.present?
          redirect_to edit_admin_organization_path(current_user.organization),
                      alert: "You can only edit your own organization."
        else
          redirect_to admin_root_path,
                      alert: "You are not associated with any organization yet."
        end
        return
      end

      authorize @organization
      super
    end

    def update
      @organization = Organization.find(params[:id])
      if current_user.owner? && @organization.id != current_user.organization_id
        redirect_to edit_admin_organization_path(current_user.organization),
                    alert: "You can only edit your own organization."
        return
      end
      authorize @organization
      super
    end

    def show
      @organization = Organization.find(params[:id])

      if current_user.owner?
        if @organization.id != current_user.organization_id
          if current_user.organization.present?
            redirect_to admin_organization_path(current_user.organization),
                        alert: "You can only view your own organization."
          else
            redirect_to admin_root_path, alert: "You don't belong to any organization."
          end
          return
        end
      end

      authorize @organization
      super
    end
  end

  permit_params :name, :description

  form do |f|
    f.inputs "Organization details" do
      f.input :name
      f.input :description
    end

    f.actions do
      f.action :submit, label: "Save changes"
      f.cancel_link admin_root_path
    end
  end

  index do
    column :name
    column :description
    actions
  end

  config.clear_action_items!
  action_item :new, only: :index do
    if current_user.owner? && current_user.organization.nil?
      link_to "Create organization", new_admin_organization_path
    end
  end

  action_item :edit, only: :show do
    if current_user.owner? && resource.id == current_user.organization_id
      link_to "Edit Organization", edit_admin_organization_path(resource)
    end
  end

  show do
    attributes_table do
      row :name
      row :description
      row :created_at
      row :updated_at
    end
  end
end
