ActiveAdmin.register Store do
  menu label: "Stores", priority: 3, if: proc { current_user.organization.present? }

  actions :all, except: [:destroy]

  config.filters = false

  controller do
    include Pundit::Authorization

    def scoped_collection
      policy_scope(super).includes(:organization)
    end

  def index
    if current_user.owner? && current_user.organization.nil?
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

    panel "Products" do
      table_for store.products do
        column :name
        column :price
        column :quantity
        column :status
        column :description
        column :categories do |product|
          product.categories.pluck(:name).join(", ")
        end
        column "Actions" do |product|
          if current_user.owner? || current_user.seller?
            links = []
            links << link_to("Edit", edit_admin_product_path(product))
            links << link_to("Delete", admin_product_path(product), method: :delete, data: { confirm: "Are you sure?" })
            safe_join(links, " | ")
          end
        end
      end
    end
  end
  action_item :new_product, only: :show do
    if current_user.owner? || current_user.seller?
      link_to "Add Product", new_admin_product_path(store_id: resource.id)
    end
  end
end