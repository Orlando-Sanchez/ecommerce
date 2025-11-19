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
end
