class ItemsController < ApplicationController
  def index
    @items = Item.search(current_user, params)
    render json: {
      items: @items.as_json(include: { feed: { include: { users_subscription: { methods: :user_title } } } }),
      last_page: @items.last_page?
    }
  end
end
