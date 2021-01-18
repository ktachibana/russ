# frozen_string_literal: true

class CrawlersController < ApplicationController
  skip_before_action :authenticate_user!
  protect_from_forgery except: :create

  def create
    unless validate_key(params.require(:key))
      head :forbidden
      return
    end

    Feed.load_all!
    head :ok
  end

  private

  def validate_key(key)
    Rails.application.credentials.crawler_key == key
  end
end
