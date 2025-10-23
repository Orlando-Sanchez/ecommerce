require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'associations' do
    it { should belong_to(:store) }
    it { should belong_to(:order) }
  end

  describe 'enums' do
    it do
      should define_enum_for(:status)
        .with_values(pending: 0, paid: 1, cancelled: 2)
        .backed_by_column_of_type(:integer)
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
  end
end
