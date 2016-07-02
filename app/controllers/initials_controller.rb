class InitialsController < ApplicationController
  skip_before_action :authenticate_user!, only: :show

  def show
    return head(:unauthorized) unless user_signed_in?
    render json: initial_states
  end
end
