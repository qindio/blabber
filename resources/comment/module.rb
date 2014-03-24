# encoding: utf-8
require 'digest'

module Blabber
  module Comment
    class << self
      attr_accessor :repository
    end

    def self.entry_from(url)
      uri = URI(url)
      schemeless_url = uri.to_s.split([uri.scheme, '://'].join).last
      Digest::MD5.new.hexdigest(schemeless_url)
    end
  end # Comment
end # Blabber

