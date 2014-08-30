class RootController < ApplicationController
  def index
    logger.info(MultiJson.engine)
    @items = Item.search(current_user, params)
    @tags = current_user.subscriptions.tag_counts
  end
end
