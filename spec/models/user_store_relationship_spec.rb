require "rails_helper"

RSpec.describe "User - Store relationship", type: :model do
  it "associates user with store through store_assignment" do
    user = create(:user)
    store = create(:store)

    create(:store_assignment, user: user, store: store)

    expect(user.stores).to include(store)
    expect(store.sellers).to include(user)
  end
end
