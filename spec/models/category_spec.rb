require 'rails_helper'

RSpec.describe Category, type: :model do
  subject(:category) { build(:category) }

  describe 'associations' do
    it { should have_and_belong_to_many(:products) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
