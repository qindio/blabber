# encoding: utf-8
require 'sinatra/base'
require_relative './api/helpers'
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
      ADMIN_ID = SecureRandom.uuid
    end

    helpers do
      include Blabber::Helpers
    end
  end # Api
end # Blabber

