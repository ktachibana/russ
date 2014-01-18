class RootController < ApplicationController
  before_filter :authenticate_user!

  def index
    @items = Item.user(current_user).search(params)
  end
end
