class ItemsController < ApplicationController
  def index
    @items = Item.user(current_user).search(params)
    render json: {
      items:  @items.as_json(include: { feed: { include: { users_subscription: { methods: :user_title } } } }),
      last_page: @items.last_page?
    }
  end
end
