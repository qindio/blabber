# encoding: utf-8
require 'minitest/autorun'
require 'rack/test'
require 'json'

require_relative '../../api'

def app
  Blabber::Api.new
end

include Blabber

describe Api do
  include Rack::Test::Methods

  before do
    @headers = { "CONTENT_TYPE" => "application/json" }
    Comment.repository.flush
  end

  describe 'post /sessions' do
    it 'creates an admin session if credentials match' do
      post '/sessions', Services::Authenticator.new.admin_credentials.to_json, @headers
      last_response.status.must_equal 201
    end

    it 'returns 401 otherwise' do
      post '/sessions', {}.to_json, @headers
      last_response.status.must_equal 401
    end
  end

  describe 'delete /sessions/:session_id' do
    it 'logs the admin out' do
      post '/sessions', Services::Authenticator.new.admin_credentials.to_json, @headers
      last_response.status.must_equal 201
      session_id = JSON.parse(last_response.body).fetch("id")

      delete "/sessions/#{session_id}"
      last_response.status.must_equal 204
    end
  end
end # Blabber::Api

