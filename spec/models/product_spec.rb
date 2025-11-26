require 'rails_helper'

RSpec.describe Product, type: :model do
  subject(:product) { build(:product) }

  describe 'associations' do
    it { should belong_to(:store).optional }
    it { should belong_to(:user).optional }
    it { should have_and_belong_to_many(:categories) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).only_integer.is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { should validate_presence_of(:status) }
  end

  describe 'enum status' do
    it do
      should define_enum_for(:status)
        .with_values(available: 0, out_of_stock: 1, discontinued: 2, unavailable: 3)
        .backed_by_column_of_type(:integer)
    end
  end
end
