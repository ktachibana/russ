class TagsController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        @tags = current_user.subscriptions.tag_counts
      end
    end
  end
end
