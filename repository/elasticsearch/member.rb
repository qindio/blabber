# encoding: utf-8
require 'elasticsearch'

module Blabber
  module Repository
    class Elasticsearch
      def initialize(connection, index, type)
        @connection = connection
        @index = index
        @type = type
      end

      def store(id, data)
        connection.index(index: index, type: type, id: id, body: data.to_hash)
      end

      def fetch(id)
        connection.get_source(index: index, type: type, id: id)
      rescue MultiJson::ParseError
        raise KeyError
      end

      def delete(id)
        connection.delete(index: index, type: type, id: id)
      end

      def flush
        connection.delete_by_query(index: index, type: type, q: "id:*")
      end

      private

      attr_reader :connection, :index, :type
    end # Elasticsearch
  end # Repository
end # Blabber

