class InitialsController < ApplicationController
  def show
    render json: { user: current_user, tags: current_user.subscriptions.tag_counts }
  end
end
