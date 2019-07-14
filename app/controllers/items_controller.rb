class ItemsController < ApplicationController
  def index
    @items = Item.search(current_user, search_params)
  end

  private

  def search_params
    params.permit(:tag, :subscription_id, :page, :hide_default)
  end
end
