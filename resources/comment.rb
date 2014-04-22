# encoding: utf-8
require 'digest'
require_relative './comment/collection'
require_relative './comment/member'

module Blabber
  module Comment
    def self.repository(kind=:member)
      @repository.fetch(kind.to_sym, @repository.fetch(:member))
    end

    def self.repository=(*repository)
      @repository = { 
        member: repository.flatten.first,
        collection: repository.flatten.last
      }
    end

    def self.entry_from(url)
      uri = URI(url)
      schemeless_url = uri.to_s.split([uri.scheme, '://'].join).last
      Digest::MD5.new.hexdigest(schemeless_url)
    end
  end # Comment
end # Blabber

