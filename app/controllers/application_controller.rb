# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  after_action :set_csrf_token_header, :set_flash_header

  private

  def record_invalid(error)
    respond_to do |f|
      f.json do
        render(json: { type: 'validation', errors: error.record.errors },
               status: :unprocessable_entity) # Railsのデフォルトに従う。Roy Fieldingも言っている。
      end
      f.any { raise error }
    end
  end

  def render_json_ok
    render json: { status: 'OK' }
  end

  def set_csrf_token_header
    response.headers['X-CSRF-Token'] = form_authenticity_token
  end

  def set_flash_header
    messages = flash.to_a
    response.headers['X-Flash-Messages'] = Rack::Utils.escape_path(messages.to_json) if messages.present?
    flash.clear
  end

  def initial_states
    { user: current_user, tags: current_user.subscriptions.tag_counts }
  end
end
