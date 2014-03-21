# encoding: utf-8
require 'set'
require 'json'
require_relative './module'
require_relative '../exceptions'

module Blabber
  module Comment
    class Collection
      include Enumerable

      attr_reader :id

      def initialize(id, members=[], member_klass=Comment::Member)
        @id = id
        @members = Set.new(members)
        @member_klass = member_klass
        @operations = []
      end

      def add(member)
        member.validate!
        members.add(member)
        operations.push([:add, member.attributes])
        self
      end

      def remove(member)
        members.delete(member)
        operations.push([:remove, member.attributes])
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
        self
      end

      def fetch
        self.members = Comment.repository.fetch(id)
          .map { |attributes| member_klass.new(attributes) }
        self
      end

      def each(&block)
        members.each(&block)
      end

      def to_json(*args)
        members.to_a.to_json
      end

      private

      attr_reader :members, :operations, :member_klass
      attr_writer :members
    end
  end # Comment
end # Blabber

