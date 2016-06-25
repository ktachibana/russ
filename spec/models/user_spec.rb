require 'spec_helper'

describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:subscriptions).dependent(:destroy) }
    it { is_expected.to have_many(:feeds).through(:subscriptions) }
  end
end
