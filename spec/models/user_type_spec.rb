require 'rails_helper'

RSpec.describe UserType, type: :model do
  subject(:user_type) { build(:user_type) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
  end
end