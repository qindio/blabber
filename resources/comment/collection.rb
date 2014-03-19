# encoding: utf-8
require 'set'

module Blabber
  module Comment
    class Collection

      attr_reader :id

      def initialize(id, members=[])
        @id = id
        @members = Set.new(members)
        @operations = []
      end

      def add(member)
        member.validate!
        members.add(member)
        operations.push([:add, member])
        self
      end

      def remove(member)
        members.delete(member)
        operations.push([:remove, member])
        self
      end

      def clear
        members.clear
        operations.push([:clear])
        self
      end

      def empty?
        members.empty?
      end

      def sync
        Comment.repository.apply(id, operations)
      end

      private

      attr_reader :members, :operations
    end
  end # Comment
end # Blabber

