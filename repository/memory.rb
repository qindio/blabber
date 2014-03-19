# encoding: utf-8

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
        memory.store(id, memory.fetch(id, []).push(*members))
      end

      def remove(id, *members)
        data = memory.fetch(id, [])
        members.each { |member| data.delete(member) }
        memory.store(id, data)
      end

      alias_method :clear, :delete

      private

      attr_reader :memory
    end
  end 
end # Blabber

