require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '.rescue_from' do
    describe 'ActiveRecord::RecordInvalid' do
      controller do
        skip_before_filter :authenticate_user!, :authenticate_user_from_token!

        def index
          FactoryGirl.create(:user, email: '', password: '')
        end
      end

      it 'HTMLをリクエストしたときはHTMLでエラーを返す' do
        expect { get :index }.to raise_error(ActiveRecord::RecordInvalid)
        expect(response.content_type).to start_with('text/html')
      end

      it 'JSONをリクエストしたときはJSONでエラーを返す' do
        request.accept = 'application/json'
        get :index
        is_expected.to respond_with(:unprocessable_entity)
        expect(response.content_type).to start_with('application/json')
        parsed = JSON.parse(response.body)
        expect(parsed).to eq('type' => 'validation',
                             'errors' => { 'email' => ['入力してください'], 'password' => ['入力してください'] })
      end
    end
  end
end
