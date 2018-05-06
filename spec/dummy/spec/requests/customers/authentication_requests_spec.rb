require 'dummy/spec/rails_helper'

describe 'Authentication - Customer', type: :request do
  describe 'POST #create' do
    context 'with invalid params' do
      it 'should return 422 - invalid login credentials' do
        @customer = create(:user)
        post '/customers/sign_in', params: attributes_for(:user).merge(password: 'paas')

        expect(response).to have_http_status(422)
        expect(response_errors).to include('Invalid login credentials')
      end
    end

    context 'with valid params' do
      it 'should login user - valid login credentials' do
        @customer = create(:user)
        post '/customers/sign_in', params: attributes_for(:user)

        expect(response).to have_http_status(200)
        expect(response.headers['Access-Token']).not_to eq('')
        expect(response.headers['Refresh-Token']).not_to eq('')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with invalid params' do
      it 'should return 401 - missing access token' do
        @customer = create(:user)
        delete '/customers/sign_out'

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Access token is missing in the request')
      end

      it 'should return 401 - invalid access token' do
        @customer = create(:user)
        delete '/customers/sign_out', headers: {'Authorization' => "Bearer 1232143"}

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Invalid access token')
      end

      it 'should return 401 - expired access token' do
        @customer = create(:user)
        expired_access_token = access_token_for_resource(@customer, 'user', true)

        delete '/customers/sign_out', headers: {'Authorization' => "Bearer #{expired_access_token}"}

        expect(response).to have_http_status(401)
        expect(response_errors).to include('Token expired')
      end
    end

    context 'with valid params' do
      it 'should login user - valid login credentials' do
        @customer = create(:user)
        access_token = access_token_for_resource(@customer, 'user')

        delete '/customers/sign_out', headers: {'Authorization' => "Bearer #{access_token}"}

        expect(response).to have_http_status(200)
      end
    end
  end
end