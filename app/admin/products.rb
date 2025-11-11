ActiveAdmin.register Product do
  permit_params :name, :price, :description, :store_id, :quantity, :status

  controller do
    include Pundit::Authorization

    def scoped_collection
      policy_scope(super)
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

      if @product.save
        redirect_to admin_store_path(@product.store), notice: "Product created successfully."       
      else
        render :new
      end
    end

    def edit
      @product = Product.find(params[:id])
      authorize @product
      super
    end

    def update
      @product = Product.find(params[:id])
      authorize @product
      if @product.update(permitted_params[:product])
        redirect_to admin_store_path(@product.store), notice: "Product created successfully."
      else
        render :edit
      end
    end

    def show
      @product = Product.find(params[:id])
      authorize @product
      super
   end

    def destroy
      @product = Product.find(params[:id])
      authorize @product
      @product.destroy
      redirect_to admin_products_path, notice: "Product deleted successfully."
    end
  end

  form do |f|
    f.inputs "Product details" do
      f.input :name
      f.input :price
      f.input :quantity

      f.input :status, as: :select,
              collection: Product::STATUS_LABELS.map { |key, label| [label, key] },
              include_blank: "Select a status"

      f.input :description
      f.input :store_id, as: :hidden, input_html: { value: f.object.store_id }
    end
    f.actions
  end

  show do
    attributes_table title: "Product Details" do
      row :id
      row :name
      row :price
      row :quantity
      row :status
      row :description
      row :created_at
      row :updated_at
    end

    panel "" do
      div do
        link_to "Back to Products", admin_products_path, class: "button"
      end
    end
  end
end