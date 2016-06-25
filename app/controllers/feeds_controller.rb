class FeedsController < ApplicationController
  def index
    @subscriptions = owned_subscriptions.preload(:tags, feed: :latest_item).order(:id).search(params)
  end

  private

  def owned_subscriptions
    current_user.subscriptions
  end
end
