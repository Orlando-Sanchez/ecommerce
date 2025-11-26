require "rails_helper"

RSpec.describe ProductPolicy, type: :policy do
  let(:organization) { create(:organization) }
  let(:other_org)   { create(:organization) }

  let(:owner) do
    create(:user, :owner, organization: organization)
  end

  let(:seller) do
    create(:user, :seller, organization: organization)
  end

  let(:customer) { create(:user, :customer) }

  let(:store_in_org) { create(:store, organization: organization) }
  let(:other_store)  { create(:store, organization: other_org) }

  let!(:product_in_store) { create(:product, store: store_in_org) }
  let!(:product_owned_by_seller) { create(:product, store: store_in_org, user: seller) }
  let!(:product_in_other_org) { create(:product, store: other_store) }

  describe "Scope" do
    it "returns products for owner's organization" do
      scope = ProductPolicy::Scope.new(owner, Product).resolve
      expect(scope).to include(product_in_store)
      expect(scope).to include(product_owned_by_seller)
      expect(scope).not_to include(product_in_other_org)
    end

    it "returns products for seller (owned or assigned stores)" do
      StoreAssignment.create!(user: seller, store: store_in_org)

      scope = ProductPolicy::Scope.new(seller, Product).resolve
      expect(scope).to include(product_owned_by_seller)
      expect(scope).to include(product_in_store)
      expect(scope).not_to include(product_in_other_org)
    end

    it "returns none for customer" do
      scope = ProductPolicy::Scope.new(customer, Product).resolve
      expect(scope).to be_empty
    end
  end

  describe "permissions" do
    context "owner user" do
      it "can manage products in their organization" do
        policy = ProductPolicy.new(owner, product_in_store)
        expect(policy.show?).to be true
        expect(policy.edit?).to be true
        expect(policy.update?).to be true
        expect(policy.destroy?).to be true
      end

      it "cannot manage products outside their organization" do
        policy = ProductPolicy.new(owner, product_in_other_org)
        expect(policy.show?).to be false
        expect(policy.edit?).to be false
      end
    end

    context "seller user" do
      before do
        StoreAssignment.create!(user: seller, store: store_in_org)
      end

      it "can manage products they own" do
        policy = ProductPolicy.new(seller, product_owned_by_seller)
        expect(policy.show?).to be true
        expect(policy.edit?).to be true
      end

      it "can manage products in assigned stores" do
        policy = ProductPolicy.new(seller, product_in_store)
        expect(policy.show?).to be true
        expect(policy.edit?).to be true
      end

      it "cannot manage products in other organizations" do
        policy = ProductPolicy.new(seller, product_in_other_org)
        expect(policy.show?).to be false
      end
    end

    context "customer user" do
      it "cannot create or manage products" do
        policy = ProductPolicy.new(customer, product_in_store)
        expect(policy.show?).to be false
        expect(policy.new?).to be false
        expect(policy.create?).to be false
      end
    end
  end
end
