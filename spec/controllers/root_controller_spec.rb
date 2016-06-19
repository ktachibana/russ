require 'spec_helper'

RSpec.describe RootController, type: :controller do
  describe 'GET :index' do
    render_views

    def action
      get :index
    end

    it 'サインインしていなくても表示できる' do
      action
      flash.to_h
      is_expected.to respond_with(:ok)
    end
  end
end
