require 'rails_helper'

RSpec.describe ActiveAdmin::PagePolicy do
  subject(:policy) { described_class.new(user, :page) }

  context "when the user is a seller" do
    let(:seller_type) { create(:user_type, :seller) }
    let(:user) { create(:user, user_types: [ seller_type ]) }

    it "grants access to the dashboard" do
      expect(policy.show?).to be true
    end
  end

  context "when the user is a customer" do
    let(:customer_type) { create(:user_type, :customer) }
    let(:user) { create(:user, user_types: [ customer_type ]) }

    it "denies access to the dashboard" do
      expect(policy.show?).to be false
    end
  end

  context "when the user isn't signed in" do
    let(:user) { nil }

    it "denies access to the dashboard" do
      expect(policy.show?).to be false
    end
  end
end
