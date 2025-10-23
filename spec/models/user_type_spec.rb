require 'rails_helper'

RSpec.describe UserType, type: :model do
  subject(:user_type) { build(:user_type) }

  describe 'associations' do
    it { should have_and_belong_to_many(:users) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
  end
end
