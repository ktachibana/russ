class RootController < ApplicationController
  before_filter :authenticate_user!

  def index
    user = current_user
    @items = Item.latest(user).page(params[:page])
    params[:tag_id].try do |id|
      @items = @items.by_tag_id(id)
    end
  end
end
