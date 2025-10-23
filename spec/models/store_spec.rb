require 'rails_helper'

RSpec.describe Store, type: :model do
  subject(:store) { build(:store) }

  describe 'associations' do
    it { should belong_to(:organization) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
  end
end
