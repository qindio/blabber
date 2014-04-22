# encoding: utf-8
require 'json'

module Blabber
  module Repository
    module Redis
      class SortedSet
        def initialize(connection, score_block)
          @connection = connection
          @score_block = score_block
        end

        def fetch(id, type=nil)
          members = connection.zrange(id, 0, -1)
          raise KeyError if members.empty?
          members.map { |member| JSON.parse(member) }
        end

        def apply(id, operations)
          connection.multi {
            operations.each { |operation|
              command, args = operation[0], operation[1..-1]
              self.send(command, id, *args)
            }
          }
        end

        def add(id, *members)
          members = members.map { |member| 
            [score_block.call(member), member.to_hash.to_json ]
          }
          connection.zadd(id, members)
        end

        def remove(id, *members)
          members = members.map { |member| member.to_hash.to_json }
          connection.zrem(id, members)
        end

        def clear(id)
          connection.del(id)
        end

        def flush
          connection.flushdb
        end

        private

        attr_reader :connection
        attr_reader :score_block
      end # SortedSet
    end # Redis
  end # Repository
end # Blabber

