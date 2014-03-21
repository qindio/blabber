# encoding: utf-8
require 'sinatra/base'
require 'securerandom'
require_relative './helpers'

module Blabber
  class Api < Sinatra::Base
    post "/sessions" do
      begin
        if admin_match?(payload)
          session["user_id"] = ADMIN_ID
          return [201, { id: SecureRandom.uuid }.to_json]
        end

        [401]
      rescue KeyError
        [401]
      end
    end

    delete "/sessions/:session_id" do
      session["user_id"] = nil
      [204]
    end
  end # Api
end # Blabber

