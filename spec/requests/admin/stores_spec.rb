require "rails_helper"
require "cgi"

RSpec.describe "Admin::Stores", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:owner_without_org) { create(:user, :owner, :without_org) }
  let(:owner_with_org)    { create(:user, :owner) }
  let(:seller_with_org)   { create(:user, :seller) }
  let(:customer)          { create(:user, :customer) }

  let(:store_in_owner_org) { create(:store, organization: owner_with_org.organization) }
  let(:other_store)        { create(:store) }

  describe "INDEX GET /admin/stores" do
    it "shows organization's stores to an owner with org" do
      store_in_owner_org
      sign_in owner_with_org, scope: :user

      get admin_stores_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(CGI.escapeHTML(store_in_owner_org.name))
      expect(response.body).not_to include(CGI.escapeHTML(other_store.name))
    end

    it "redirects owner without org to admin root" do
      sign_in owner_without_org, scope: :user
      get admin_stores_path

      expect(response).to redirect_to(admin_root_path)
    end

    it "shows assigned stores to a seller" do
      store = store_in_owner_org
      StoreAssignment.create!(user: seller_with_org, store: store)
      # ensure seller belongs to same organization
      seller_with_org.update!(organization: owner_with_org.organization)

      sign_in seller_with_org, scope: :user
      get admin_stores_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(CGI.escapeHTML(store.name))
    end

    it "redirects customer to public root" do
      sign_in customer, scope: :user
      get admin_stores_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "NEW GET /admin/stores/new" do
    it "renders form for owner with org" do
      sign_in owner_with_org, scope: :user
      get new_admin_store_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Store details")
    end

    it "redirects non-owner (seller) to admin root when accessing new" do
      seller_with_org.update!(organization: owner_with_org.organization)
      sign_in seller_with_org, scope: :user

      get new_admin_store_path
      expect(response).to redirect_to(admin_root_path).or redirect_to(admin_stores_path)
    end

    it "redirects owner without org to admin root" do
      sign_in owner_without_org, scope: :user
      get new_admin_store_path

      expect(response).to redirect_to(admin_root_path)
    end
  end

  describe "CREATE POST /admin/stores" do
    let(:valid_params) { { store: { name: "New Store", description: "Desc" } } }

    it "creates store and assigns to owner's organization" do
      sign_in owner_with_org, scope: :user

      expect {
        post admin_stores_path, params: valid_params
      }.to change(Store, :count).by(1)

      expect(Store.last.organization).to eq(owner_with_org.organization)
    end

    it "prevents seller from creating store (redirects)" do
      seller_with_org.update!(organization: owner_with_org.organization)
      sign_in seller_with_org, scope: :user

      expect {
        post admin_stores_path, params: valid_params
      }.not_to change(Store, :count)

      # controller will redirect non-authorized sellers
      expect(response).to redirect_to(admin_root_path).or redirect_to(admin_stores_path)
    end

    it "prevents customer from creating store" do
      sign_in customer, scope: :user

      expect {
        post admin_stores_path, params: valid_params
      }.not_to change(Store, :count)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "EDIT/UPDATE" do
    it "allows owner to edit their store" do
      sign_in owner_with_org, scope: :user
      get edit_admin_store_path(store_in_owner_org)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Store details")

      patch admin_store_path(store_in_owner_org), params: { store: { name: "Updated" } }
      expect(response).to redirect_to(admin_stores_path)
      expect(store_in_owner_org.reload.name).to eq("Updated")
    end

    it "prevents seller from updating a store (redirects)" do
      store = store_in_owner_org
      seller_with_org.update!(organization: owner_with_org.organization)
      StoreAssignment.create!(user: seller_with_org, store: store)

      sign_in seller_with_org, scope: :user

      patch admin_store_path(store), params: { store: { name: "Nope" } }

      expect(response).to redirect_to(admin_root_path).or redirect_to(admin_stores_path)
      expect(store.reload.name).not_to eq("Nope")
    end
  end

  describe "SHOW GET /admin/stores/:id" do
    it "shows the store to owner" do
      sign_in owner_with_org, scope: :user
      get admin_store_path(store_in_owner_org)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(CGI.escapeHTML(store_in_owner_org.name))
    end

    it "shows the store to assigned seller" do
      store = store_in_owner_org
      seller_with_org.update!(organization: owner_with_org.organization)
      StoreAssignment.create!(user: seller_with_org, store: store)

      sign_in seller_with_org, scope: :user
      get admin_store_path(store)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(CGI.escapeHTML(store.name))
    end

    it "prevents customer from viewing store" do
      sign_in customer, scope: :user
      get admin_store_path(store_in_owner_org)

      expect(response).to redirect_to(root_path)
    end
  end
end
