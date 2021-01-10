# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '.rescue_from' do
    let(:bypass_rescue?) { false }

    describe 'ActiveRecord::RecordInvalid' do
      controller do
        skip_before_action :authenticate_user!

        def index
          User.create!(email: '', password: '')
        end
      end

      def action
        get :index
      end

      it 'HTMLをリクエストしたときはHTMLでエラーを返す' do
        expect { action }.to raise_error(ActiveRecord::RecordInvalid)
        expect(response.media_type).to eq('text/html')
      end

      it 'JSONをリクエストしたときはJSONでエラーを返す' do
        request.accept = 'application/json'
        action
        is_expected.to respond_with(:unprocessable_entity)
        expect(response.media_type).to eq('application/json')
        parsed = JSON.parse(response.body)
        expect(parsed).to eq('type' => 'validation',
                             'errors' => { 'email' => ['入力してください'], 'password' => ['入力してください'] })
      end
    end
  end
end
