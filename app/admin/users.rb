ActiveAdmin.register User do
  menu label: "Sellers", priority: 5

  actions :index, :show, :destroy

  permit_params :email, :password, :password_confirmation, :organization_id

  controller do
    include Pundit::Authorization

    before_action :authorize_owner!

    def scoped_collection
      if current_user.owner?
        User.joins(:user_types)
            .where(user_types: { name: "Seller" }, organization_id: current_user.organization_id)
      else
        User.none
      end
    end

    private

    def authorize_owner!
      unless current_user.owner?
        redirect_to admin_root_path, alert: "You are not authorized to access this section."
      end
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
    column :fullname
    column :email
    column "Roles" do |user|
      user.user_types.pluck(:name).join(", ")
    end
    column :invitation_sent_at
    column :invitation_accepted_at
    column("Invitation status") do |user|
      if user.invitation_accepted_at.present?
        status_tag("Accepted", class: "ok")
      elsif user.invitation_sent_at.present?
        status_tag("Pending", class: "warning")
      else
        status_tag("Not invited", class: "default")
      end
    end
    actions defaults: true do |user|
      if user.invitation_sent_at.present? && user.invitation_accepted_at.nil?
        link_to "Resend Invitation",
                resend_invitation_admin_user_path(user),
                method: :post,
                data: { confirm: "Resend invitation to #{user.email}?" }
      end
    end
  end

  sidebar "Invite a Seller", only: :index do
    if current_user.owner? && current_user.organization.present?
      render partial: "admin/users/invite_seller_form", 
            locals: { user: User.new, stores: current_user.organization.stores }
    else
      span "You don't have an organization or stores yet."
    end
  end

  member_action :resend_invitation, method: :post do
    user = User.find(params[:id])
    authorize_owner!

    if user.invitation_sent_at.present? && user.invitation_accepted_at.nil?
      user.invite!(invited_by: current_user)
      redirect_to admin_users_path, notice: "Invitation resent to #{user.email}."
    else
      redirect_to admin_users_path, alert: "User has already accepted the invitation."
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
        user.invite!(invited_by: current_user)
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
end
