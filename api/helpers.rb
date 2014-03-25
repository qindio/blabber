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
  end # Helpers
end # Blabber

