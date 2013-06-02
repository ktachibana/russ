require 'spec_helper'

describe Item do
  describe 'validations' do
    it { should validate_presence_of(:rss_source_id) }
  end

  describe 'associations' do
    it { should belong_to(:rss_source) }
  end
end
