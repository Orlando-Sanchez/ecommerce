require "rails_helper"

RSpec.describe StorePolicy, type: :policy do
  let(:organization) { create(:organization) }
  let(:other_org)    { create(:organization) }

  let(:owner)        { create(:user, :owner, organization: organization) }
  let(:owner_no_org) { create(:user, :owner, organization: nil) }

  let(:seller)       { create(:user, :seller, organization: organization) }
  let(:seller_no_org){ create(:user, :seller, organization: nil) }

  let(:customer)     { create(:user, :customer) }

  let(:store)        { create(:store, organization: organization) }
  let(:store_other)  { create(:store, organization: other_org) }

  before do
    store.sellers << seller
  end

  subject { described_class }

  describe "#index?" do
    it "allows owner with organization" do
      expect(subject.new(owner, Store).index?).to eq(true)
    end

    it "denies owner without organization" do
      expect(subject.new(owner_no_org, Store).index?).to eq(false)
    end

    it "allows seller with organization" do
      expect(subject.new(seller, Store).index?).to eq(true)
    end

    it "denies seller without organization" do
      expect(subject.new(seller_no_org, Store).index?).to eq(false)
    end

    it "denies customers" do
      expect(subject.new(customer, Store).index?).to eq(false)
    end
  end

  describe "#show?" do
    it "allows owner to see stores of their organization" do
      expect(subject.new(owner, store).show?).to eq(true)
    end

    it "denies owner from other organizations" do
      expect(subject.new(owner, store_other).show?).to eq(false)
    end

    it "allows seller assigned to store" do
      expect(subject.new(seller, store).show?).to eq(true)
    end

    it "denies seller if not assigned to store" do
      new_store = create(:store, organization: organization)
      expect(subject.new(seller, new_store).show?).to eq(false)
    end

    it "denies seller without organization" do
      expect(subject.new(seller_no_org, store).show?).to eq(false)
    end

    it "denies customer" do
      expect(subject.new(customer, store).show?).to eq(false)
    end
  end

  describe "#create?" do
    it "allows owner with organization" do
      expect(subject.new(owner, Store).create?).to eq(true)
    end

    it "denies owner without organization" do
      expect(subject.new(owner_no_org, Store).create?).to eq(false)
    end

    it "denies seller" do
      expect(subject.new(seller, Store).create?).to eq(false)
    end

    it "denies customer" do
      expect(subject.new(customer, Store).create?).to eq(false)
    end
  end

  describe "#new?" do
    it "mirrors create?" do
      expect(subject.new(owner, Store).new?).to eq(true)
      expect(subject.new(seller, Store).new?).to eq(false)
    end
  end

  describe "#update?" do
    it "allows owner to update their own store" do
      expect(subject.new(owner, store).update?).to eq(true)
    end

    it "denies owner updating store from other org" do
      expect(subject.new(owner, store_other).update?).to eq(false)
    end

    it "denies seller even if assigned" do
      expect(subject.new(seller, store).update?).to eq(false)
    end

    it "denies customer" do
      expect(subject.new(customer, store).update?).to eq(false)
    end
  end

  describe "#destroy?" do
    it "always denies deletion" do
      expect(subject.new(owner, store).destroy?).to eq(false)
    end
  end

  describe "Scope" do
    context "owner with organization" do
      it "returns only stores from user's organization" do
        resolved = Pundit.policy_scope(owner, Store)
        expect(resolved).to include(store)
        expect(resolved).not_to include(store_other)
      end
    end

    context "seller assigned to some stores" do
      it "returns only assigned stores" do
        resolved = Pundit.policy_scope(seller, Store)
        expect(resolved).to include(store)
        expect(resolved).not_to include(store_other)
      end
    end

    context "seller without organization" do
      it "returns empty scope" do
        resolved = Pundit.policy_scope(seller_no_org, Store)
        expect(resolved).to be_empty
      end
    end

    context "customer" do
      it "returns empty scope" do
        resolved = Pundit.policy_scope(customer, Store)
        expect(resolved).to be_empty
      end
    end
  end
end