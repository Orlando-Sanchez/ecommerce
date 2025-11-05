ActiveAdmin.register Store do
  actions :all, except: [:destroy]

  controller do
    include Pundit::Authorization

    def scoped_collection
      policy_scope(super)
    end

    def new
      @store = Store.new
      authorize @store
      super
    end

    def create
      @store = Store.new(permitted_params[:store])
      @store.organization = current_user.organization
      authorize @store

      if @store.save
        redirect_to edit_admin_store_path(@store), notice: "Store creada correctamente."
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
        redirect_to edit_admin_store_path(@store), notice: "Store actualizada correctamente."
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
    # Owners pueden editar name y description; sellers solo gestionan asignaciones si quieres
    if current_user.owner?
      [:name, :description, seller_ids: []]
    else
      []
    end
  end

  index do
    column :name
    column :description
    column :organization
    column "Sellers" do |store|
      store.sellers.map(&:email).join(", ")
    end
    actions
  end

  form do |f|
    f.inputs "Detalles de la Store" do
      f.input :name if current_user.owner?
      f.input :description if current_user.owner?
      f.input :sellers, as: :check_boxes, collection: User.where(user_type: "Seller") if current_user.owner?
    end
    f.actions
  end
end