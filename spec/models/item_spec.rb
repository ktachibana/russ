require 'spec_helper'

describe Item do
  describe 'associations' do
    it { is_expected.to belong_to(:feed) }
  end

  describe '.search' do
    describe ':tag' do
      it 'tagパラメータでタグ検索できる' do
        items = [%w(a), %w(a b), nil].map do |tag|
          create(:item) do |item|
            create(:subscription, feed: item.feed, tag_list: tag)
          end
        end
        expect(Item.search(tag: %w(a b))).to match_array(items.values_at(1))
        expect(Item.search(tag: %w(a))).to match_array(items.values_at(0, 1))
        expect(Item.search(tag: %w(b))).to match_array(items.values_at(1))
        expect(Item.search(tag: %w())).to match_array(items)
      end
    end

    describe ':page' do
      let(:per_page) { Kaminari.config.default_per_page }
      it 'ページを絞る' do
        create_list(:item, per_page + 1)
        expect(Item.search(page: 1).count).to eq(per_page)
        expect(Item.search(page: 2).count).to eq(1)
        expect(Item.search(page: nil).count).to eq(per_page)
      end
    end
  end

  describe '.default_scope' do
    it 'published_atの新しい順' do
      items = [3, 1, 2].map do |n|
        create(:item, published_at: n.days.ago)
      end
      expect(Item.all).to eq(items.values_at(1, 2, 0))
    end
  end

  describe '.user' do
    it 'ユーザーのItemだけを取得する' do
      user = create(:user)
      other_user = create(:user)

      create(:subscription, user: user) do |subscription|
        create(:item, feed: subscription.feed, title: '3')
      end
      create(:subscription, user: user) do |subscription|
        create(:item, feed: subscription.feed, title: '2')
        create(:item, feed: subscription.feed, title: '1')
      end
      create(:subscription, user: other_user) do |subscription|
        create(:item, feed: subscription.feed, title: '4')
      end

      expect(Item.user(user).map(&:title)).to match_array(%w(1 2 3))
    end
  end
end
