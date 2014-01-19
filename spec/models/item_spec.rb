require 'spec_helper'

describe Item do
  describe 'validations' do
    it { should validate_presence_of(:feed_id) }
  end

  describe 'associations' do
    it { should belong_to(:feed) }
  end

  describe '.search' do
    describe ':tag' do
      it 'tagパラメータでタグ検索できる' do
        items = [%w(a), %w(a b), nil].map do |tag|
          create(:item, feed: create(:feed, tag_list: tag))
        end
        Item.search(tag: %w(a b)).should =~ items.values_at(1)
        Item.search(tag: %w(a)).should =~ items.values_at(0, 1)
        Item.search(tag: %w(b)).should =~ items.values_at(1)
        Item.search(tag: %w()).should =~ items
      end
    end

    describe ':page' do
      let(:per_page) { Kaminari.config.default_per_page }
      it 'ページを絞る' do
        create_list(:item, per_page + 1)
        Item.search(page: 1).count.should == per_page
        Item.search(page: 2).count.should == 1
        Item.search(page: nil).count.should == per_page
      end
    end
  end

  describe '.default_scope' do
    it 'published_atの新しい順' do
      items = [3, 1, 2].map do |n|
        create(:item, published_at: n.days.ago)
      end
      Item.all.should == items.values_at(1, 2, 0)
    end
  end

  describe '.user' do
    it 'ユーザーのItemだけを取得する' do
      user = create(:user)
      other_user = create(:user)

      create(:feed, user: user) do |feed|
        create(:item, feed: feed, title: '3')
      end
      create(:feed, user: user) do |feed|
        create(:item, feed: feed, title: '2')
        create(:item, feed: feed, title: '1')
      end
      create(:feed, user: other_user) do |feed|
        create(:item, feed: feed, title: '4')
      end

      Item.user(user).map(&:title).should =~ %w[1 2 3]
    end
  end
end
