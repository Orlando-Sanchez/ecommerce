require "rails_helper"

RSpec.describe "Admin::Users", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:owner_with_org) { create(:user, :owner) }
  let(:seller) { create(:user, :seller) }

  describe "INDEX GET /admin/users" do
    it "allows owner with org to view index" do
      sign_in owner_with_org, scope: :user

      get admin_users_path

      expect(response).to have_http_status(:ok)
      # page renders Users listing
      expect(response.body).to include("Users")
    end

    it "redirects non-owner to admin root" do
      sign_in seller, scope: :user
      get admin_users_path

      expect(response).to redirect_to(admin_root_path)
    end
  end

  describe "CREATE POST /admin/users/create_invitation" do
    before do
      sign_in owner_with_org, scope: :user
    end

    it "resends invitation to an existing user (not accepted) and assigns org/store and seller role" do
      existing = create(:user, :without_org)
      create(:user_type, :seller)
      store = create(:store, organization: owner_with_org.organization)

      post create_invitation_admin_users_path, params: { user: { email: existing.email, store_ids: [ store.id ] } }

      expect(response).to redirect_to(admin_users_path)
      existing.reload
      expect(existing.organization_id).to eq(owner_with_org.organization_id)
      expect(existing.user_types.pluck(:name)).to include("Seller")
      expect(existing.store_ids).to include(store.id)
    end

    it "creates a new invited user and assigns organization, seller role and stores" do
      store = create(:store, organization: owner_with_org.organization)
      new_email = "new_seller@example.com"
      create(:user_type, :seller)

      expect {
        post create_invitation_admin_users_path, params: { user: { email: new_email, store_ids: [ store.id ] } }
      }.to change(User, :count)

      invited = User.find_by(email: new_email)
      expect(invited).not_to be_nil
      expect(invited.organization_id).to eq(owner_with_org.organization_id)
      expect(invited.user_types.pluck(:name)).to include("Seller")
      expect(invited.store_ids).to include(store.id)
    end
  end

  describe "POST /admin/users/:id/resend_invitation" do
    before do
      sign_in owner_with_org, scope: :user
    end

    it "resends invitation when invitation_sent_at present and not accepted" do
      invited = User.invite!(email: "temp_invite@example.com", invited_by: owner_with_org)

      expect(invited.invitation_sent_at).not_to be_nil
      expect(invited.invitation_accepted_at).to be_nil

      post resend_invitation_admin_user_path(invited)

      expect(response).to redirect_to(admin_users_path)
      # invitation token refreshed on resend (or at least invitation_sent_at present)
      invited.reload
      expect(invited.invitation_sent_at).not_to be_nil
    end

    it "does not resend when user already accepted invitation" do
      accepted = create(:user)
      # simulate accepted invite
      accepted.update!(invitation_accepted_at: Time.current)

      post resend_invitation_admin_user_path(accepted)

      expect(response).to redirect_to(admin_users_path)
      follow_redirect!
      expect(response.body).to match(/already accepted/i)
    end
  end
end
