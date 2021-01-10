# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:feed) }
  end

  describe '.search' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    describe 'user' do
      it 'ユーザーのItemだけを取得する' do
        feed1 = create(:feed) do |feed|
          create(:item, feed: feed, title: '3', published_at: 1.day.ago)
        end
        feed2 = create(:feed) do |feed|
          create(:item, feed: feed, title: '2', published_at: 2.days.ago)
          create(:item, feed: feed, title: '1', published_at: 3.days.ago)
        end
        feed3 = create(:feed) do |feed|
          create(:item, feed: feed, title: '4', published_at: 4.days.ago)
        end
        user.feeds = [feed1, feed3]
        other_user.feeds = [feed2, feed3]
      end

      it 'ユーザーのSubscriptionだけがfeedに含まれる' do
        feed = create(:feed, item_count: 1)
        users_subscription = create(:subscription, feed: feed, user: user)
        others_subscription = create(:subscription, feed: feed, user: other_user)

        expect(described_class.search(user)[0].feed.users_subscription).to eq(users_subscription)
        expect(described_class.search(other_user)[0].feed.users_subscription).to eq(others_subscription)
      end
    end

    describe ':tag' do
      it 'tagパラメータでタグ検索できる' do
        items = [%w[a], %w[a b], nil].map do |tag|
          create(:item) do |item|
            create(:subscription, feed: item.feed, tag_list: tag, user: user)
          end
        end
        expect(described_class.search(user, tag: %w[a b])).to match_array(items.values_at(1))
        expect(described_class.search(user, tag: %w[a])).to match_array(items.values_at(0, 1))
        expect(described_class.search(user, tag: %w[b])).to match_array(items.values_at(1))
        expect(described_class.search(user, tag: %w[])).to match_array(items)
      end
    end

    describe ':subscription_id' do
      it 'subscription_idで絞り込める' do
        subscriptions = create_list(:subscription, 2, user: user, item_count: 1)
        expect(described_class.search(user, subscription_id: subscriptions[0].id)).to eq(subscriptions[0].feed.items)
        expect(described_class.search(user, subscription_id: subscriptions[1].id)).to eq(subscriptions[1].feed.items)
      end
    end

    describe ':hide_default' do
      it 'hide_defaultパラメータを渡されたらhide_defaultなFeedは返さない' do
        subscriptions = [
          create(:subscription, user: user, hide_default: false, item_count: 1),
          create(:subscription, user: user, hide_default: true, item_count: 1),
        ]
        expect(Item.search(user, hide_default: true)).to eq(subscriptions[0].feed.items)
      end

      it '他の条件を指定されたら無効になる' do
        subscriptions = [
          create(:subscription, user: user, tag_list: %w(a), hide_default: false, item_count: 1),
          create(:subscription, user: user, tag_list: %w(a), hide_default: true, item_count: 1),
        ]
        expect(Item.search(user, tag: %w(a), hide_default: true)).to match_array(subscriptions.map { |s| s.feed.items }.flatten)
      end
    end

    describe ':page' do
      let(:per_page) { Kaminari.config.default_per_page }

      it 'ページを絞る' do
        feed = create(:feed)
        create_list(:item, per_page + 1, feed: feed)
        user.feeds = [feed]
        expect(described_class.search(user, page: 1).count).to eq(per_page)
        expect(described_class.search(user, page: 2).count).to eq(1)
        expect(described_class.search(user, page: nil).count).to eq(per_page)
      end
    end
  end

  describe '.default_scope' do
    it 'published_atの新しい順' do
      items = [3, 1, 2].map do |n|
        create(:item, published_at: n.days.ago)
      end
      expect(described_class.all).to eq(items.values_at(1, 2, 0))
    end
  end

  describe '.before_save' do
    before { Timecop.freeze }

    describe '#correct_published_at' do
      it '未来の日付が設定されていたら現在時刻に置き換える' do
        expect(create(:item, published_at: 1.day.from_now).published_at).to eq(Time.current)
        expect(create(:item, published_at: 1.day.from_now.to_date).published_at).to eq(Time.current)
      end

      it 'nilの時は現在時刻を設定する' do
        expect(create(:item, published_at: nil).published_at).to eq(Time.current)
      end

      it 'すでに設定された時刻をnilにしようとしたら元に戻す' do
        item = create(:item, published_at: 1.day.ago)
        expect { item.update!(published_at: nil) }.not_to change { item.published_at }
      end

      it '直接新しい日付を設定することはできる' do
        item = create(:item, published_at: 2.days.ago)
        expect { item.update!(published_at: 1.day.ago) }.to change { item.published_at }.to(1.day.ago)
      end
    end
  end
end
