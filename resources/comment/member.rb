# encoding: utf-8
require 'securerandom'
require 'json'
require_relative './module'

module Blabber
  class InvalidResource < StandardError; end

  module Comment
    class Member
      ATTRIBUTES = [:id, :name, :text, :created_at]

      attr_reader :errors, :id, :name, :text, :created_at

      def initialize(attributes={})
        set_attributes(attributes)

        @id ||= next_id
        @created_at ||= Time.now
      end

      def validate
        self.errors = { name: [], text: [] }
        errors[:name].push(:must_be_present) if name.nil? || name.empty?
        errors[:text].push(:must_be_present) if text.nil? || text.empty?
        self
      end

      def validate!
        validate
        raise InvalidResource unless valid?
      end

      def valid?
        self.errors.values.flatten.empty?
      end

      def to_json(*args)
        attributes.to_json(*args)
      end

      def attributes
        Hash[ATTRIBUTES.map { |key| [key, self.send(key)] }]
      end

      def fetch
        set_attributes(JSON.parse(Comment.repository.fetch(id)))
      end

      def sync
        validate!
        Comment.repository.store(id, self.to_json)
        self
      end

      private

      attr_writer :errors, :id, :name, :text, :created_at

      def next_id
        SecureRandom.uuid
      end

      def set_attributes(attributes={})
        attributes
          .select { |key, value| ATTRIBUTES.include?(key.to_sym) }
          .each { |key, value| self.send("#{key}=", value) }
      end
    end # Member
  end # Comment
end # Blabber

