# encoding: utf-8

module Blabber
  module Helpers
    def payload
      request.body.rewind
      JSON.parse(request.body.read.to_s)
    end

    def admin?
      session["user_id"] == Blabber::Api::ADMIN_ID
    end

    def admin_match?(credentials)
      credentials.fetch("user") == Blabber::Api::ADMIN_CREDENTIALS.fetch("user") &&
      credentials.fetch("password") == Blabber::Api::ADMIN_CREDENTIALS.fetch("password")
    rescue KeyError
      false
    end
  end # Helpers
end # Blabber

