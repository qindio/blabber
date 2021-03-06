# encoding: utf-8
require 'set'

module Blabber
  module Repository
    class Memory
      def initialize
        @memory = {}
      end

      def store(id, data)
        memory.store(id, data)
      end

      def fetch(id)
        memory.fetch(id)
      end

      def delete(id)
        memory.delete(id)
      end

      def apply(id, operations)
        operations.each { |operation|
          command, args = operation[0], operation[1..-1]
          self.send(command, id, *args)
        }
      end

      def add(id, *members)
        memory.store(id, memory.fetch(id, Set.new).add(*members))
      end

      def remove(id, *members)
        data = memory.fetch(id, Set.new)
        members.each { |member| data.delete(member) }
        memory.store(id, data)
        memory.delete(id) if data.empty?
      end

      alias_method :clear, :delete

      def flush
        memory.clear
      end

      private

      attr_reader :memory
    end
  end 
end # Blabber

