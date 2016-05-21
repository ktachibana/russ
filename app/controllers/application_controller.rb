class ApplicationController < ActionController::Base
  acts_as_token_authentication_handler_for User
  before_filter :authenticate_user!

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

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
end
