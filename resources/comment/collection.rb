# encoding: utf-8
require 'set'
require 'json'
require_relative '../comment'
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
        members.add(member.attributes)
        operations.push([:add, member.attributes])
        self
      end

      def remove(member)
        members.delete(member.attributes)
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
        repository.apply(id, operations)
        self
      end

      def fetch
        self.members = repository.fetch(id)
          .map { |attributes| member_klass.new(attributes) }
        self
      rescue KeyError, Errno::ENOENT
        raise ResourceNotFound
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

      def repository
        Comment.repository(:collection)
      end
    end
  end # Comment
end # Blabber

