require 'spec_helper'

RSpec.describe 'application/_items.json', type: :view do
  let(:subscription) { create(:subscription) }
  let!(:item) { create(:item, feed: subscription.feed) }

  it 'render json' do
    render 'application/items.json.jbuilder', items: Item.search(subscription.user)

    data = JSON.parse(rendered, symbolize_names: true)
    data[:items].tap do |items|
      expect(items).to be_a(Array)

      items[0].tap do |i|
        expect(i[:id]).to eq(item.id)
        expect(i[:title]).to eq(item.title)
        expect(i[:description]).to eq(item.description)
        expect(i[:link]).to eq(item.link)
        expect(i[:publishedAt]).to eq(item.published_at.as_json) # http://apidock.com/rails/ActiveSupport/TimeWithZone/as_json
        expect(i[:feedId]).to eq(item.feed_id)

        i[:feed].tap do |f|
          feed = item.feed
          expect(f[:id]).to eq(feed.id)
          expect(f[:url]).to eq(feed.url)
          expect(f[:title]).to eq(feed.title)
          expect(f[:linkUrl]).to eq(feed.link_url)
          expect(f[:description]).to eq(feed.description)

          f[:usersSubscription].tap do |s|
            expect(s[:id]).to eq(subscription.id)
            expect(s[:userTitle]).to eq(subscription.user_title)
          end
        end
      end
    end

    expect(data[:pagination]).to eq(perPage: 25, totalCount: 1)
  end
end
