ActiveAdmin.register Store do
  actions :all, except: [:destroy]

  controller do
    include Pundit::Authorization

    def scoped_collection
      policy_scope(super).includes(:organization)
    end

    def index
      if current_user.organization.nil?
        redirect_to admin_root_path, alert: "There are no stores yet, please create your organization first."
        return
      end

      super
    end

    def new
      if current_user.owner? && current_user.organization.nil?
        redirect_to admin_root_path, alert: "You must belong to an organization before creating a store."
        return
      end

      @store = Store.new
      authorize @store
      super
    end

    def create
      @store = Store.new(permitted_params[:store])
      @store.organization = current_user.organization
      authorize @store

      if @store.save
        redirect_to admin_stores_path, notice: "Store created successfully."
      else
        render :new
      end
    end

    def edit
      @store = Store.find(params[:id])
      authorize @store
      super
    end

    def update
      @store = Store.find(params[:id])
      authorize @store

      if @store.update(permitted_params[:store])
        redirect_to admin_stores_path, notice: "Store updated successfully."
      else
        render :edit
      end
    end

    def show
      @store = Store.find(params[:id])
      authorize @store
      super
    end
  end

  permit_params do
    if current_user.owner?
      [:name, :description]
    else
      []
    end
  end

  index do
    column :name
    column :description
    actions
  end

  form do |f|
    f.inputs "Store details" do
      if current_user.owner?
        f.input :name
        f.input :description
      end
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :description
    end
  end
end