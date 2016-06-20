class ApplicationController < ActionController::Base
  acts_as_token_authentication_handler_for User
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
      f.any { fail error }
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
    logger.error(messages)
    response.headers['X-Flash-Messages'] = Base64.strict_encode64(messages.to_json) if messages.present?
  end

  def initial_states
    { user: current_user, tags: current_user.subscriptions.tag_counts }
  end
end
