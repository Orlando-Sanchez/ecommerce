require 'rails_helper'

RSpec.describe Order, type: :model do
  subject(:order) { build(:order) }

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:store) }
  end

  describe 'validations' do
    it { should validate_presence_of(:status) }
  end
  
  describe 'enum status' do
    it do
      should define_enum_for(:status)
        .with_values(pending: 0, completed: 1, canceled: 2)
        .backed_by_column_of_type(:integer)
    end
  end
end
