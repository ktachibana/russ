require 'spec_helper'

describe RssSource do
  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:url) }
  end
end
