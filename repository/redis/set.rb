# encoding: utf-8
require 'json'

module Blabber
  module Repository
    module Redis
      class Set
        def initialize(connection, 
          serialize=default_serializer,
          deserialize=default_deserializer
        )
          @connection = connection
          @serialize = serialize
          @deserialize = deserialize
        end

        def fetch(id, type=nil)
          members = connection.smembers(id)
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
          connection.sadd(id, members.map(&serialize))
        end

        def remove(id, *members)
          connection.srem(id, members.map(&serialize))
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

        private

        attr_reader :connection, :serialize, :deserialize
      end # Set
    end # Redis
  end # Repository
end # Blabber

