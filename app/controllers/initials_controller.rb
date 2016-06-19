class InitialsController < ApplicationController
  skip_before_action :authenticate_user!, only: :show
  skip_before_action :authenticate_user_from_token!, only: :show

  def show
    return head(:unauthorized) unless user_signed_in?
    render json: { user: current_user, tags: current_user.subscriptions.tag_counts }
  end
end
