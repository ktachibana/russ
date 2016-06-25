class TagsController < ApplicationController
  def index
    @tags = current_user.subscriptions.tag_counts
  end
end
