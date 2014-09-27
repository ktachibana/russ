class RootController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json do
        @items = Item.search(current_user, params)
        @tags = current_user.subscriptions.tag_counts
      end
    end
  end
end
