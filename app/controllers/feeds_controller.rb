class FeedsController < ApplicationController
  def index
    respond_to do |f|
      f.html
      f.json { @subscriptions = owned_subscriptions.includes({ feed: :latest_item }, :tags).order(:id).search(params) }
    end
  end

  def show
    @subscription = owned_subscriptions.includes(feed: :items).find_by!(feed_id: params[:id])
    @items = @subscription.feed.items.page(params[:page])
  end

  private

  def owned_subscriptions
    current_user.subscriptions
  end
end
