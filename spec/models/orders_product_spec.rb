require 'rails_helper'

RSpec.describe OrdersProduct, type: :model do
  describe 'associations' do
    it { should belong_to(:order) }
    it { should belong_to(:product) }
  end

  describe 'validations' do
    it { should validate_presence_of(:unit_price) }
    it { should validate_presence_of(:product_data) }

    it do
      should validate_numericality_of(:unit_price)
        .is_greater_than_or_equal_to(0)
    end
  end
end
