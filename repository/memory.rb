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
        #memory.store(id, []) unless memory.has_key?(id)

        operations.each { |operation|
          command, args = operation[0], operation[1..-1]
          self.send(command, id, *args)
        }
      end

      def add(id, *args)
        memory.store(id, memory.fetch(id, []).push(*args))
      end

      def remove(id, *args)
        data = memory.fetch(id, [])
        args.each { |item| data.delete(item) }
        memory.store(id, data)
      end

      alias_method :clear, :delete

      private

      attr_reader :memory
    end
  end 
end # Blabber

