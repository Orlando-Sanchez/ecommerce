require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe 'associations' do
    it { should belong_to(:organization).optional }
    it { should have_and_belong_to_many(:user_types) }
    it { should have_many(:store_assignments).dependent(:destroy) }
    it { should have_many(:stores).through(:store_assignments) }
    it { should have_many(:products).dependent(:nullify) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe '.ransackable attributes and associations' do
    it 'exposes the expected ransackable attributes' do
      expect(User.ransackable_attributes).to match_array(%w[id email created_at organization_id])
    end

    it 'exposes the expected ransackable associations' do
      expect(User.ransackable_associations).to match_array([ "organization", "user_types" ])
    end
  end

  describe 'role helpers' do
    it 'correctly identifies seller/owner/customer roles' do
      seller = create(:user, :seller)
      owner = create(:user, :owner)
      customer = create(:user, :customer)

      expect(seller.seller?).to be true
      expect(seller.owner?).to be false

      expect(owner.owner?).to be true
      expect(owner.seller?).to be false

      expect(customer.customer?).to be true
      expect(customer.seller?).to be false
    end
  end

  describe '#normalize_user_types' do
    it 'removes Customer role when user is an Owner' do
      user = create(:user)
      owner_type = create(:user_type)
      customer_type = create(:user_type, :customer)

      user.user_types = [ owner_type, customer_type ]
      user.save!

      # call the private normalization method directly
      user.send(:normalize_user_types)
      user.reload

      expect(user.user_types.pluck(:name)).to include('Owner')
      expect(user.user_types.pluck(:name)).not_to include('Customer')
    end

    it 'removes Customer role when Seller belongs to an organization' do
      org = create(:organization)
      user = create(:user, :seller)
      customer_type = create(:user_type, :customer)

      user.organization = org
      user.user_types << customer_type
      user.save!

      user.send(:normalize_user_types)
      user.reload

      expect(user.user_types.map(&:name)).to include('Seller')
      expect(user.user_types.map(&:name)).not_to include('Customer')
    end

    it 'keeps Customer role when Seller has no organization' do
      user = create(:user, :seller, :without_org)
      customer_type = create(:user_type, :customer)

      user.user_types << customer_type
      user.save!

      user.send(:normalize_user_types)
      user.reload

      expect(user.user_types.map(&:name)).to include('Customer')
      expect(user.user_types.map(&:name)).to include('Seller')
    end
  end
end
