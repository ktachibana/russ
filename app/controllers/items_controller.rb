class ItemsController < ApplicationController
  def index
    @items = Item.user(current_user).search(params)
    render json: @items.to_json(include: { feed: { include: { users_subscription: { methods: :user_title } } } })
  end
end
