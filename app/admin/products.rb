ActiveAdmin.register Product do
  permit_params :name, :price, :description, :store_id, :quantity, :status, category_ids: []

  controller do
    include Pundit::Authorization
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  before_action :check_access
    def find_and_authorize_product
      product = Product.find_by(id: params[:id])
      unless product
        redirect_to admin_root_path, alert: "Product not found." and return nil
      end

      begin
        authorize product
      rescue Pundit::NotAuthorizedError
        if current_user.owner? && current_user.organization.present?
          redirect_to admin_stores_path, alert: "You are not authorized to access this product." and return nil
        elsif current_user.seller? && current_user.organization.present?
          redirect_to admin_stores_path, alert: "You are not authorized to access this product." and return nil
        else
          redirect_to admin_root_path, alert: "You are not authorized to access this product." and return nil
        end
      end

      product
    end

    def new
      @product = Product.new
      @product.store_id = params[:store_id]
      authorize @product
      super
    end

    def create
      @product = Product.new(permitted_params[:product])
      authorize @product

      @product.user = current_user if current_user.organization.nil?

      if @product.save
        redirect_to admin_store_path(@product.store), notice: "Product created successfully."
      else
        render :new
      end
    end

    def scoped_collection
      policy_scope(super)
    end

    def index
      if current_user&.owner?
        if current_user.organization.present?
          redirect_to admin_stores_path and return
        else
          redirect_to admin_root_path and return
        end
      end

      if current_user&.seller?
          if current_user.organization.nil?
            begin
              index!
              return
            rescue ActiveAdmin::AccessDenied => e
              @products = policy_scope(Product)
              render html: @products.map { |p| ERB::Util.html_escape(p.name) }.join("<br>").html_safe and return
            rescue => e
              raise
            end
          else
          redirect_to admin_stores_path, alert: "You are not authorized to view this page." and return
          end
      end

      if current_user&.customer?
        redirect_to root_path, alert: "You are not authorized to view this page." and return
      else
        redirect_to admin_root_path, alert: "You are not authorized to view this page." and return
      end
    end

    def edit
      @product = find_and_authorize_product
      return unless @product
      render :edit
    end

    def update
      @product = find_and_authorize_product
      return unless @product

      if @product.update(permitted_params[:product])
        if @product.store.present?
          redirect_to admin_store_path(@product.store), notice: "Product updated successfully."
        else
          redirect_to admin_root_path, notice: "Product updated successfully."
        end
      else
        render :edit
      end
    end

    def show
      @product = find_and_authorize_product
      return unless @product
      render :show
    end

    def destroy
      @product = find_and_authorize_product
      return unless @product

      store = @product.store
      @product.destroy
      if store.present?
        redirect_to admin_store_path(store), notice: "Product deleted successfully."
      else
        redirect_to admin_root_path, notice: "Product deleted successfully."
      end
    end

    private

    def user_not_authorized(exception)
      if current_user&.owner? && current_user.organization.present?
        redirect_to admin_stores_path, alert: "You are not authorized to perform that action."
      elsif current_user&.seller?
        redirect_to admin_root_path, alert: "You are not authorized to perform that action."
      else
        redirect_to root_path, alert: exception.message
      end
    end

    def check_access
      user = current_user
        if user&.customer? && !user&.owner? && !user&.seller?
          redirect_to root_path, alert: "You are not authorized to access this section."
          nil
        end
    end
  end

  index title: proc {
    if current_user.seller? && current_user.organization.nil?
      "My Products"
    else
      "Products"
    end
  } do
    selectable_column
    id_column
    column :name
    column :price
    column :quantity
    column :status
    column("Categories") { |p| p.categories.map(&:name).join(", ") }
    column :store
    actions
  end

  form do |f|
    f.inputs "Product details" do
      f.input :name
      f.input :price
      f.input :quantity
      f.input :status,
              as: :select,
              collection: Product.statuses.keys.map { |key| [ key.humanize, key ] },
              include_blank: "Select a status"
      f.input :description
      f.input :store_id, as: :hidden, input_html: { value: f.object.store_id }

      f.input :categories,
              as: :select,
              collection: Category.all.map { |c| [ c.name, c.id ] },
              input_html: { multiple: true }
    end

    f.actions do
      f.action :submit, label: "Save Product"
      f.cancel_link(admin_root_path)
    end
  end

  show do
    attributes_table title: "Product Details" do
      row :id
      row :name
      row :price
      row :quantity
      row :status
      row :description
      row("Categories") { |p| p.categories.map(&:name).join(", ") }
      row :created_at
      row :updated_at
    end

    panel "" do
      div do
        link_to "Back to Store", admin_store_path(resource.store), class: "button" if resource.store
      end
    end
  end
end
