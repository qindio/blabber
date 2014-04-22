# encoding: utf-8
require_relative './redis/member'
require_relative './redis/set'

module Blabber
  module Repository
    module Redis
      def self.unsorted(connection)
        [Member.new(connection), Set.new(connection)]
      end
    end # Redis
  end # Repository
end # Blabber

