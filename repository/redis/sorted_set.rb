# encoding: utf-8
require 'json'

module Blabber
  module Repository
    module Redis
      class SortedSet
        def initialize(connection, scorer,
          serialize=default_serializer,
          deserialize=default_deserializer
        )
          @connection = connection
          @serialize = serialize
          @deserialize = deserialize
          @serialize_and_score = scorer_and_serializer(scorer)
        end

        def fetch(id, type=nil)
          members = connection.zrange(id, 0, -1)
          raise KeyError if members.empty?
          members.map(&deserialize)
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
          connection.zadd(id, members.map(&serialize_and_score))
        end

        def remove(id, *members)
          connection.zrem(id, members.map(&serialize))
        end

        def clear(id)
          connection.del(id)
        end

        def flush
          connection.flushdb
        end

        def default_serializer
          lambda { |member| member.to_hash.to_json }
        end

        def default_deserializer
          lambda { |member| JSON.parse(member) }
        end

        def scorer_and_serializer(scorer)
          lambda { |member| [scorer.call(member), serialize.call(member) ] }
        end

        private

        attr_reader :connection, :serialize, :deserialize, :serialize_and_score
      end # SortedSet
    end # Redis
  end # Repository
end # Blabber

