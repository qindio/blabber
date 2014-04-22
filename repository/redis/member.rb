# encoding: utf-8
require 'json'

module Blabber
  module Repository
    module Redis
      class Member
        def initialize(connection)
          @connection = connection
        end

        def store(id, data)
          connection.set(id, data.to_hash.to_json)
        end

        def fetch(id)
          data = connection.get(id)
          raise KeyError unless data
          JSON.parse(data)
        end

        def delete(id)
          connection.del(id)
        end

        def flush
          connection.flushdb
        end

        private

        attr_reader :connection
      end # Member
    end # Redis
  end # Repository
end # Blabber

