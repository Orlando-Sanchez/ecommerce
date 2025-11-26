require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  let(:organization) { create(:organization) }
  let(:other_org)   { create(:organization) }

  let(:owner)       { create(:user, :owner, organization: organization) }
  let(:owner_no_org) { create(:user, :owner, :without_org) }
  let(:seller)      { create(:user, :seller, organization: organization) }
  let(:seller_other) { create(:user, :seller, organization: other_org) }
  let(:customer)    { create(:user, :customer) }

  subject { described_class }

  describe "permissions" do
    it "allows owner to access index" do
      expect(subject.new(owner, User).index?).to eq(true)
    end

    it "denies non-owner access to index (sellers/customers) but allows owners even without org" do
      expect(subject.new(seller, User).index?).to eq(false)
      expect(subject.new(customer, User).index?).to eq(false)
      expect(subject.new(owner_no_org, User).index?).to eq(true)
    end

    it "allows owner to invite and create_invitation and destroy" do
      expect(subject.new(owner, User).invite?).to eq(true)
      expect(subject.new(owner, User).create_invitation?).to eq(true)
      expect(subject.new(owner, User).destroy?).to eq(true)
    end

    it "denies invite/create/destroy to non-owners (sellers/customers) and allows owners even without org" do
      expect(subject.new(seller, User).invite?).to eq(false)
      expect(subject.new(seller, User).create_invitation?).to eq(false)
      expect(subject.new(seller, User).destroy?).to eq(false)

      expect(subject.new(customer, User).invite?).to eq(false)
      expect(subject.new(customer, User).create_invitation?).to eq(false)
      expect(subject.new(customer, User).destroy?).to eq(false)

      expect(subject.new(owner_no_org, User).invite?).to eq(true)
      expect(subject.new(owner_no_org, User).create_invitation?).to eq(true)
      expect(subject.new(owner_no_org, User).destroy?).to eq(true)
    end
  end

  describe "Scope" do
    context "when user is owner" do
      it "returns sellers from owner's organization only" do
        same = seller
        other = seller_other

        resolved = Pundit.policy_scope(owner, User)
        expect(resolved).to include(same)
        expect(resolved).not_to include(other)
      end
    end

    context "when user is not owner" do
      it "returns empty scope for seller" do
        resolved = Pundit.policy_scope(seller, User)
        expect(resolved).to be_empty
      end

      it "returns empty scope for customer" do
        resolved = Pundit.policy_scope(customer, User)
        expect(resolved).to be_empty
      end
    end
  end
end
