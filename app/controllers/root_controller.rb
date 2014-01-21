class RootController < ApplicationController
  def index
    @items = Item.user(current_user).search(params)
  end
end
