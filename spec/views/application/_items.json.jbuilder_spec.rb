require 'spec_helper'

describe 'application/_items.json', type: :view do
  let(:subscription) { create(:subscription) }
  let!(:item) { create(:item, feed: subscription.feed) }

  it 'render js' do
    render 'application/items.json.jbuilder', items: Item.search(subscription.user)

    data = JSON.parse(rendered, symbolize_names: true)
    data[:items].tap do |items|
      expect(items).to be_a(Array)

      items[0].tap do |i|
        expect(i[:id]).to eq(item.id)
        expect(i[:title]).to eq(item.title)
        expect(i[:description]).to eq(item.description)
        expect(i[:link]).to eq(item.link)
        expect(i[:feed_id]).to eq(item.feed_id)

        i[:feed].tap do |f|
          feed = item.feed
          expect(f[:id]).to eq(feed.id)
          expect(f[:url]).to eq(feed.url)
          expect(f[:title]).to eq(feed.title)
          expect(f[:link_url]).to eq(feed.link_url)
          expect(f[:description]).to eq(feed.description)

          f[:users_subscription].tap do |s|
            expect(s[:id]).to eq(subscription.id)
            expect(s[:user_title]).to eq(subscription.user_title)
          end
        end
      end
    end

    expect(data[:last_page]).to be true
  end
end
