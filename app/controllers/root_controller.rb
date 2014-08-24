class RootController < ApplicationController
  def index
    @items = Item.user(current_user).search(params)

    respond_to do |format|
      format.html
      format.json do
        render json: {
          items: @items.as_json(include: { feed: { include: { users_subscription: { methods: :user_title } } } }),
          tags: current_user.subscriptions.tag_counts
        }
      end
    end
  end
end
