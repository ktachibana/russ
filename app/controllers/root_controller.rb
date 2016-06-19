class RootController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  skip_before_action :authenticate_user_from_token!, only: :index

  def index
    respond_to do |format|
      format.html
    end
  end
end
