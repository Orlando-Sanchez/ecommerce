require "rails_helper"

RSpec.describe OrganizationPolicy do
  subject { described_class }

  let(:owner_without_org) { create(:user, :owner, :without_org) }
  let(:owner_with_org)    { create(:user, :owner) }
  let(:other_user)        { create(:user) }

  let(:org_of_owner)      { owner_with_org.organization }
  let(:other_org)         { create(:organization) }

  describe "Scope" do
    let!(:all_orgs) { create_list(:organization, 3) }

    it "returns only the org of an owner with organization" do
      scope = OrganizationPolicy::Scope.new(owner_with_org, Organization.all).resolve
      expect(scope).to contain_exactly(owner_with_org.organization)
    end

    it "returns no org when user is owner without organization" do
      scope = OrganizationPolicy::Scope.new(owner_without_org, Organization.all).resolve
      expect(scope).to be_empty
    end

    it "returns no org when user isn't an owner" do
      scope = OrganizationPolicy::Scope.new(other_user, Organization.all).resolve
      expect(scope).to be_empty
    end
  end

  describe "permissions for show?, edit?, update?" do
    context "owner with org" do
      it "allows viewing their own org" do
        policy = OrganizationPolicy.new(owner_with_org, org_of_owner)
        expect(policy).to permit_action(:show)
        expect(policy).to permit_action(:edit)
        expect(policy).to permit_action(:update)
      end

      it "forbids viewing another org" do
        policy = OrganizationPolicy.new(owner_with_org, other_org)
        expect(policy).to forbid_action(:show)
        expect(policy).to forbid_action(:edit)
        expect(policy).to forbid_action(:update)
      end
    end

    context "owner without org" do
      it "forbids show/edit/update since they have no org" do
        policy = OrganizationPolicy.new(owner_without_org, Organization.new(id: 999))
        expect(policy).to forbid_action(:show)
        expect(policy).to forbid_action(:edit)
        expect(policy).to forbid_action(:update)
      end
    end

    context "non-owner user" do
      it "forbids viewing any org" do
        policy = OrganizationPolicy.new(other_user, org_of_owner)
        expect(policy).to forbid_action(:show)
        expect(policy).to forbid_action(:edit)
        expect(policy).to forbid_action(:update)
      end
    end
  end

  describe "permissions for new? and create?" do
    let(:new_record) { Organization.new }

    it "allows owner without org to create an org" do
      policy = OrganizationPolicy.new(owner_without_org, new_record)
      expect(policy).to permit_new_and_create_actions
    end

    it "forbids owner with org to create a new org" do
      policy = OrganizationPolicy.new(owner_with_org, new_record)
      expect(policy).to forbid_new_and_create_actions
    end

    it "forbids non-owner user from creating orgs" do
      policy = OrganizationPolicy.new(other_user, new_record)
      expect(policy).to forbid_new_and_create_actions
    end
  end

  describe "permissions for destroy?" do
    it "never allows destroy" do
      [owner_with_org, owner_without_org, other_user].each do |user|
        record = user.organization || Organization.new
        policy = OrganizationPolicy.new(user, record)
        expect(policy).to forbid_action(:destroy)
      end
    end
  end
end