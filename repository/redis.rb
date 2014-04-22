# encoding: utf-8
require_relative './redis/member'
require_relative './redis/set'
require_relative './redis/sorted_set'

module Blabber
  module Repository
    module Redis
      def self.unsorted(connection)
        [Member.new(connection), Set.new(connection)]
      end

      def self.sorted(connection, score_block)
        [Member.new(connection), SortedSet.new(connection, score_block)]
      end
    end # Redis
  end # Repository
end # Blabber

