# encoding: utf-8
require 'json'

module Blabber
  module Repository
    module Redis
      class Set
        def initialize(connection)
          @connection = connection
        end

        def fetch(id, type=nil)
          members = connection.smembers(id)
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
          members = members.map { |member| member.to_hash.to_json }
          connection.sadd(id, members)
        end

        def remove(id, *members)
          members = members.map { |member| member.to_hash.to_json }
          connection.srem(id, members)
        end

        def clear(id)
          connection.del(id)
        end

        def flush
          connection.flushdb
        end

        private

        attr_reader :connection
      end # Set
    end # Redis
  end # Repository
end # Blabber

