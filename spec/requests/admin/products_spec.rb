require "rails_helper"
require "cgi"

RSpec.describe "Admin::Products", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:owner_without_org) { create(:user, :owner, :without_org) }
  let(:owner_with_org)    { create(:user, :owner) }
  let(:seller_with_org)   { create(:user, :seller) }
  let(:seller_without_org) { create(:user, :seller, :without_org) }
  let(:customer)          { create(:user, :customer) }

  let(:store_in_owner_org) { create(:store, organization: owner_with_org.organization) }
  let(:product_in_store)   { create(:product, store: store_in_owner_org) }
  let(:other_product)      { create(:product) }

  describe "INDEX GET /admin/products" do
    it "redirects owner to admin root" do
      product_in_store
      sign_in owner_with_org, scope: :user

      get admin_products_path
      expect(response).to redirect_to(admin_stores_path)
    end

    it "redirects owner without org to admin root" do
      sign_in owner_without_org, scope: :user
      get admin_products_path

      expect(response).to redirect_to(admin_root_path)
    end

    it "redirects seller with organization to admin root" do
      product = product_in_store
      StoreAssignment.create!(user: seller_with_org, store: store_in_owner_org)
      seller_with_org.update!(organization: owner_with_org.organization)

      sign_in seller_with_org, scope: :user
      get admin_products_path

      expect(response).to redirect_to(admin_stores_path)
    end

    it "shows products to seller without organization" do
      product = product_in_store
    sign_in seller_without_org, scope: :user

    get admin_products_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include(CGI.escapeHTML(product.name))
    end

    it "redirects customer to public root" do
      sign_in customer, scope: :user
      get admin_products_path

      expect(response).to redirect_to(root_path)
    end
  end

  describe "NEW/CREATE" do
    it "renders form for owner with org" do
      sign_in owner_with_org, scope: :user
      get new_admin_product_path(store_id: store_in_owner_org.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Product details")
    end

    it "allows assigned seller to access new" do
      StoreAssignment.create!(user: seller_with_org, store: store_in_owner_org)
      seller_with_org.update!(organization: owner_with_org.organization)
      sign_in seller_with_org, scope: :user

      get new_admin_product_path(store_id: store_in_owner_org.id)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Product details")
    end

    it "creates product for owner" do
      sign_in owner_with_org, scope: :user
      expect {
        post admin_products_path, params: { product: { name: "P", price: 1.0, quantity: 1, status: "available", store_id: store_in_owner_org.id, description: "Created by test" } }
      }.to change(Product, :count).by(1)
    end

    it "prevents customer from creating product" do
      sign_in customer, scope: :user
      expect {
        post admin_products_path, params: { product: { name: "P", price: 1.0, quantity: 1, status: "available", store_id: store_in_owner_org.id, description: "Created by test" } }
      }.not_to change(Product, :count)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "EDIT/UPDATE/DESTROY" do
    it "allows owner to update product" do
      sign_in owner_with_org, scope: :user
      product = product_in_store

      get edit_admin_product_path(product)
      expect(response).to have_http_status(:ok)

      patch admin_product_path(product), params: { product: { name: "Updated" } }
      expect(response).to redirect_to(admin_store_path(product.store))
      expect(product.reload.name).to eq("Updated")
    end

    it "allows assigned seller to update product" do
      product = product_in_store
      StoreAssignment.create!(user: seller_with_org, store: store_in_owner_org)
      seller_with_org.update!(organization: owner_with_org.organization)

      sign_in seller_with_org, scope: :user
      get edit_admin_product_path(product)
      expect(response).to have_http_status(:ok)

      patch admin_product_path(product), params: { product: { name: "SellerUpdated" } }
      expect(response).to redirect_to(admin_store_path(product.store))
      expect(product.reload.name).to eq("SellerUpdated")
    end

    it "prevents unassigned seller from updating product" do
      product = product_in_store
      seller_with_org.update!(organization: owner_with_org.organization)
      sign_in seller_with_org, scope: :user

  patch admin_product_path(product), params: { product: { name: "Nope" } }
  expect(response).to redirect_to(admin_stores_path).or redirect_to(admin_store_path(product.store))
      expect(product.reload.name).not_to eq("Nope")
    end

    it "allows owner to destroy product" do
      sign_in owner_with_org, scope: :user
      product = product_in_store

      expect { delete admin_product_path(product) }.to change(Product, :count).by(-1)
    end
  end
end
