ActiveAdmin.register Organization do
  menu false

  breadcrumb { [] }
  config.filters = false
  actions :all, except: [ :destroy ]

  controller do
    include Pundit::Authorization
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    before_action :redirect_if_already_has_org, only: [ :new, :create ]

    def user_not_authorized
      if current_user&.owner? && current_user.organization.present?
        if %w[edit update].include?(action_name)
          redirect_to edit_admin_organization_path(current_user.organization)
        else
          redirect_to admin_organization_path(current_user.organization)
        end
      else
        redirect_to admin_root_path, alert: "You are not authorized to view this page."
      end
    end

    def redirect_if_already_has_org
      return unless current_user&.owner? && current_user.organization.present?

      redirect_to edit_admin_organization_path(current_user.organization), notice: "You already belong to an organization."
    end

    def scoped_collection
      if current_user.owner?
        super.where(id: current_user.organization_id)
      else
        super.none
      end
    end

    def index
      unless current_user.owner? || current_user.seller?
        redirect_to root_path, alert: "You are not authorized to view this page." and return
      end

      if current_user.owner?
        if current_user.organization.present?
          redirect_to admin_organization_path(current_user.organization)
        else
          redirect_to admin_root_path
        end
        return
      end

      if current_user.seller?
        redirect_to admin_root_path, alert: "You are not authorized to view organizations." and return
      end

      super
    end

    def new
      @organization = Organization.new
      authorize @organization
      super
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
      @organization = Organization.find_by(id: params[:id])
      return redirect_to(admin_root_path, alert: "Organization not found.") if @organization.nil?

      authorize @organization
      super
    end

    def update
      @organization = Organization.find_by(id: params[:id])
      return redirect_to(admin_root_path, alert: "Organization not found.") if @organization.nil?

      authorize @organization
      super
    end

    def show
      @organization = Organization.find_by(id: params[:id])
      return redirect_to(admin_root_path, alert: "Organization not found.") if @organization.nil?

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
