# encoding: utf-8

module Blabber
  module Services
    class Authenticator
      def authenticate(credentials)
        credentials.fetch("user") == admin_credentials.fetch("user") &&
        credentials.fetch("password") == admin_credentials.fetch("password")
      rescue KeyError
        false
      end

      def admin_credentials
        configured_credentials || null_credentials
      end

      def configured_credentials
        return false unless credentials_configured?
        @configured_credentials ||= 
          JSON.parse(File.read("./admin.json") || {}.to_json)
      end

      def credentials_configured?(basedir=File.dirname(__FILE__))
        File.exists?(File.join(basedir, "../admin.json"))
      end

      def null_credentials
        { "user" => nil, "password" => nil } 
      end
    end # Authenticator
  end # Services
end # Blabber

