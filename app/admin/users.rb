ActiveAdmin.register User do
  menu label: "Sellers", priority: 5

  actions :index, :show, :edit, :update, :destroy

  permit_params :email, :password, :password_confirmation, :organization_id, store_ids: []

  controller do
    include Pundit::Authorization

    before_action :authorize_owner!
    before_action :set_user, only: [ :show, :edit, :update, :destroy ]
    before_action :authorize_user_for_owner!, only: [ :show, :edit, :update, :destroy ]

    def scoped_collection
      return User.none unless current_user.owner? && current_user.organization.present?

      store_users = User.joins(:stores)
                        .where(stores: { id: current_user.organization.store_ids })

      invited_users = User.where(invited_by_id: current_user.id)

      User.where(id: store_users.pluck(:id) + invited_users.pluck(:id)).distinct
    end

    def show
    end

    def edit
    end

    def update
      if @user.update(permitted_params[:user])
        redirect_to admin_users_path, notice: "User updated successfully."
      else
        render :edit
      end
    end

    def destroy
      @user.destroy
      redirect_to admin_users_path, notice: "User deleted successfully."
    end

    private

    def authorize_owner!
      unless current_user.owner?
        redirect_to admin_root_path, alert: "You are not authorized." and return
      end
    end

    def set_user
      @user = User.find_by(id: params[:id])
      unless @user
        redirect_to admin_users_path, alert: "User not found." and return
      end
    end

    def authorize_user_for_owner!
      allowed_user_ids = User.joins(:stores)
                             .where(stores: { id: current_user.organization.store_ids })
                             .pluck(:id) +
                         User.where(invited_by_id: current_user.id).pluck(:id)

      unless allowed_user_ids.include?(@user.id)
        redirect_to admin_users_path, alert: "You cannot access this user." and return
      end
    end
  end

  collection_action :create_invitation, method: :post do
    authorize_owner!

    user_email = (params.dig(:user, :email) || params[:email]).to_s.strip.downcase
    store_ids  = params.dig(:user, :store_ids) || []
    seller_type = UserType.find_by(name: "Seller")

    user = User.find_by(email: user_email)

    if user.present?
      if user.invitation_accepted_at.blank?
        user.invite!(current_user)
        user.update(organization_id: current_user.organization_id)
        user.user_types << seller_type if seller_type && !user.user_types.include?(seller_type)
        user.store_ids = store_ids

        redirect_to admin_users_path, notice: "Invitation resent to existing user #{user_email}"
      else
        redirect_to admin_users_path, alert: "User #{user_email} already exists and has accepted the invitation."
      end
    else
      user = User.invite!(email: user_email, invited_by: current_user)

      if user.persisted?
        user.update(organization_id: current_user.organization_id)
        user.user_types << seller_type if seller_type && !user.user_types.include?(seller_type)
        user.store_ids = store_ids

        redirect_to admin_users_path, notice: "Invitation sent to #{user_email}"
      else
        redirect_to admin_users_path, alert: user.errors.full_messages.join(", ")
      end
    end
  end

  member_action :resend_invitation, method: :post do
    user = User.find(params[:id])

    if user.invitation_sent_at.present? && user.invitation_accepted_at.nil?
      user.invite!(current_user)
      redirect_to admin_users_path, notice: "Invitation resent to #{user.email}."
    else
      redirect_to admin_users_path, alert: "User has already accepted the invitation."
    end
  end

  sidebar "Invite a Seller", only: :index do
    if current_user.owner? &&
      current_user.organization.present? &&
      current_user.organization.stores.exists?

      render partial: "admin/users/invite_seller_form",
             locals: { user: User.new, stores: current_user.organization.stores }
    else
      span "You don't have an organization or stores yet."
    end
  end

  remove_filter :invited_by_type, :invited_by_id, :invitation_token,
                :invitation_created_at, :invitation_sent_at,
                :invitation_accepted_at, :invitations_count

  filter :email
  filter :created_at
  filter :invitation_accepted_at, label: "Accepted invitation"
  filter :invitation_sent_at, label: "Invitation sent"

  index do
    selectable_column
    id_column
    column :email
    column :invitation_sent_at
    column :invitation_accepted_at

    actions defaults: true do |user|
      if user.invitation_sent_at.present? && user.invitation_accepted_at.nil?
        link_to "Resend Invitation",
                { action: :resend_invitation, id: user.id },
                method: :post,
                data: { confirm: "Resend invitation to #{user.email}?" }
      end
    end
  end

  form do |f|
    f.inputs "User details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :store_ids,
              as: :check_boxes,
              collection: current_user.organization.stores,
              label: "Assign to Stores"
    end
    f.actions
  end
end
