# encoding: utf-8
require 'sinatra/base'
require_relative './api/sessions'
require_relative './api/comments'
require_relative './repository/memory'
require_relative './resources/comment/comment'

module Blabber
  class Api < Sinatra::Base
    use Rack::Session::Cookie, {
      key:          'blabber',
      domain:       'example.com',
      path:         '/',
      secret:       'changeme',
      expire_after:  86400 * 7 # 1 week
    }

    configure do
      Comment.repository = Repository::Memory.new
      ADMIN_CREDENTIALS = JSON.parse(File.read("./admin.json"))
      ADMIN_ID = SecureRandom.uuid
    end

    helpers do
      def payload
        request.body.rewind
        JSON.parse(request.body.read.to_s)
      end

      def admin?
        session["user_id"] == ADMIN_ID
      end

      def admin_match?(credentials)
        credentials.fetch("user") == ADMIN_CREDENTIALS.fetch("user") &&
        credentials.fetch("password") == ADMIN_CREDENTIALS.fetch("password")
      end
    end
  end # Api
end # Blabber

