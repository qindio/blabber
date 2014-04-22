# encoding: utf-8
require 'json'

module Blabber
  module Repository
    class Redis
      def initialize(connection)
        @connection = connection
      end

      def store(id, data)
        connection.set(id, data.to_hash.to_json)
      end

      def fetch(id, type=nil)
        type ||= connection.type(id)

        if type == 'set'
          connection.smembers(id).map { |member| JSON.parse(member) }
        else
          data = connection.get(id)
          raise KeyError unless data
          JSON.parse(data)
        end
      end

      def delete(id)
        connection.del(id)
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

      alias_method :clear, :delete

      def flush
        connection.flushdb
      end

      private

      attr_reader :connection
    end
  end
end
