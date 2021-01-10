require 'rails_helper'

RSpec.describe 'フィードの購読', type: :system do
  def login_on_form
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password'
    click_button 'Sign in'
  end

  let(:user) { create(:user, password: 'password') }

  it '1つのフィードを購読' do
    feed = create(:feed)
    item = create(:item, feed: feed, description: 'my description')
    subscription = create(:subscription, user: user, feed: feed, title: 'my title')

    visit '/'
    login_on_form

    within '.items .item' do
      expect(page)
        .to have_content(item.title)
        .and have_content(item.description)
        .and have_content(subscription.title)
    end
  end
end
