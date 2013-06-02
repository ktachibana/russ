class RootController < ApplicationController
  before_filter :authenticate_user!

  def index
    user = current_user
    @items = Item.latest(user).page(params[:page])
  end
end
