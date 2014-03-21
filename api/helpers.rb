# encoding: utf-8

module Blabber
  module Helpers
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
end

