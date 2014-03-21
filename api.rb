# encoding: utf-8
require 'sinatra/base'
require_relative './api/comments'
require_relative './repository/memory'
require_relative './resources/comment/comment'

module Blabber
  
  class Api < Sinatra::Base
    configure do
      Comment.repository = Repository::Memory.new
    end

    helpers do
      def payload
        request.body.rewind
        JSON.parse(request.body.read.to_s)
      end
    end
  end # Api
end # Blabber

