require 'rails_helper'

RSpec.describe Organization, type: :model do
  subject(:organization) { build(:organization) }

  describe 'associations' do
    it { should have_many(:users) }
    it { should have_many(:stores) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
  end
end
