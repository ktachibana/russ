class RootController < ApplicationController
  def index
    @items = Item.search(current_user, params)
    @tags = current_user.subscriptions.tag_counts
  end
end
