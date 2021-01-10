# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'フィードの購読', skip: 'webdriver/firefox', type: :feature do
  def login_on_form
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password'
    click_button 'Sign in'
  end

  let(:user) { create(:user, password: 'password') }

  it '1つのフィードを購読', :js do
    feed = create(:feed)
    item = create(:item, feed: feed, description: 'my description')
    subscription = create(:subscription, user: user, feed: feed, title: 'my title')

    visit root_path
    expect(page).to have_current_path(new_user_session_path, ignore_query: true)

    login_on_form
    expect(page).to have_current_path(root_path, ignore_query: true)

    within '.items .item' do
      expect(page).to have_content(item.title)
        .and have_content(item.description)
        .and have_content(subscription.title)
    end
  end
end
