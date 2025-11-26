require "rails_helper"
require "cgi"

RSpec.describe "Admin::Organizations", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:owner_without_org) { create(:user, :owner, :without_org) }
  let(:owner_with_org)    { create(:user, :owner) }
  let(:other_user)        { create(:user) }
  let(:seller)            { create(:user, :seller) }

  let(:org_of_owner)      { owner_with_org.organization }
  let(:other_org)         { create(:organization) }

  describe "INDEX GET /admin/organizations" do
    it "redirects owner with organization to their organization's show page" do
    sign_in owner_with_org, scope: :user
    get admin_organizations_path

    expect(response).to redirect_to(admin_organization_path(org_of_owner))
  end

  it "redirects owner without organization to admin root" do
    sign_in owner_without_org, scope: :user
    get admin_organizations_path

    expect(response).to redirect_to(admin_root_path)
  end

  it "redirects seller to admin root" do
    sign_in seller, scope: :user
    get admin_organizations_path

    expect(response).to redirect_to(admin_root_path)
  end

  it "redirects customer to home page" do
    customer = create(:user, :customer)
    sign_in customer, scope: :user

    get admin_organizations_path

    expect(response).to redirect_to(root_path)
  end
  end

  describe "NEW GET /admin/organizations/new" do
    it "renders form for owner without org" do
    sign_in owner_without_org, scope: :user
    get new_admin_organization_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Organization details")
  end

  it "redirects owner with org to edit page with a notice" do
    sign_in owner_with_org, scope: :user
    get new_admin_organization_path

    expect(response).to redirect_to(edit_admin_organization_path(org_of_owner))
    follow_redirect!
    expect(response.body).to match(/You already belong to an organization/i)
  end

  it "redirects non-owner to admin root with alert" do
    sign_in other_user, scope: :user
    get new_admin_organization_path

    expect(response).to redirect_to(admin_root_path)
  end
  end

  describe "CREATE POST /admin/organizations" do
    let(:valid_params) { { organization: { name: "New Org", description: "Test Org" } } }

  it "creates organization and assigns it to owner without org" do
    sign_in owner_without_org, scope: :user

    expect {
      post admin_organizations_path, params: valid_params
    }.to change(Organization, :count).by(1)

    expect(owner_without_org.reload.organization.name).to eq("New Org")
  end

  it "does not create a second organization for an owner with org and redirects to edit" do
    sign_in owner_with_org, scope: :user

    expect {
      post admin_organizations_path, params: valid_params
    }.not_to change(Organization, :count)

    expect(response).to redirect_to(edit_admin_organization_path(org_of_owner))
  end

  it "prevents non-owner from creating organizations" do
    sign_in other_user, scope: :user

    expect {
      post admin_organizations_path, params: valid_params
    }.not_to change(Organization, :count)

    expect(response).to redirect_to(admin_root_path)
  end
  end

  describe "EDIT GET /admin/organizations/:id/edit" do
    it "allows owner to edit their organization" do
    sign_in owner_with_org, scope: :user
    get edit_admin_organization_path(org_of_owner)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Organization details")
  end

  it "redirects owner trying to edit another org to their own edit" do
    sign_in owner_with_org, scope: :user
    get edit_admin_organization_path(other_org)

    expect(response).to redirect_to(edit_admin_organization_path(org_of_owner))
  end

  it "redirects owner without org to admin root" do
    sign_in owner_without_org, scope: :user
    get edit_admin_organization_path(other_org)

    expect(response).to redirect_to(admin_root_path)
  end

  it "redirects non-owner to admin root" do
    sign_in other_user, scope: :user
    get edit_admin_organization_path(org_of_owner)

    expect(response).to redirect_to(admin_root_path)
  end
  end

  describe "UPDATE PATCH /admin/organizations/:id" do
    it "updates successfully for owner of the organization" do
    sign_in owner_with_org, scope: :user

    patch admin_organization_path(org_of_owner), params: { organization: { name: "Updated" } }

    expect(response).to redirect_to(admin_organization_path(org_of_owner))
    expect(org_of_owner.reload.name).to eq("Updated")
  end

  it "does not allow owner to update another org; redirects to their edit" do
    sign_in owner_with_org, scope: :user

    patch admin_organization_path(other_org), params: { organization: { name: "Should Not Update" } }

    expect(response).to redirect_to(edit_admin_organization_path(org_of_owner))
    expect(other_org.reload.name).not_to eq("Should Not Update")
  end

  it "prevents non-owner from updating" do
    sign_in other_user, scope: :user

    patch admin_organization_path(org_of_owner), params: { organization: { name: "Invalid" } }

    expect(response).to redirect_to(admin_root_path)
    expect(org_of_owner.reload.name).not_to eq("Invalid")
  end
  end

  describe "SHOW GET /admin/organizations/:id" do
    it "shows the organization to its owner" do
    sign_in owner_with_org, scope: :user
    get admin_organization_path(org_of_owner)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(CGI.escapeHTML(org_of_owner.name))
  end

  it "redirects owner trying to view another org to their own" do
    sign_in owner_with_org, scope: :user
    get admin_organization_path(other_org)

    expect(response).to redirect_to(admin_organization_path(org_of_owner))
  end

  it "redirects non-owner to admin root" do
    sign_in other_user, scope: :user
    get admin_organization_path(org_of_owner)

    expect(response).to redirect_to(admin_root_path)
  end

  it "redirects when organization does not exist" do
    sign_in owner_with_org, scope: :user
    get admin_organization_path(9999)

    expect(response).to redirect_to(admin_root_path)
    follow_redirect!
    expect(response.body).to match(/Organization not found/i)
  end
  end
end
