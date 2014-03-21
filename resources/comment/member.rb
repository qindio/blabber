# encoding: utf-8
require 'securerandom'
require 'json'
require 'uri'
require_relative './module'

module Blabber
  class InvalidResource < StandardError; end

  module Comment
    class Member
      ATTRIBUTES = [:id, :url, :name, :text, :created_at]

      attr_reader :errors, :id, :url, :name, :text, :created_at

      def initialize(attributes={})
        set_attributes(attributes)
        @id ||= next_id
        @created_at ||= Time.now
        @errors = {}
      end

      def page
        uri = URI(url)
        uri.to_s.split([uri.scheme, '://'].join).last
      end

      def validate
        add_error(:url, :must_be_present) if url.nil? || url.empty?
        add_error(:name, :must_be_present) if name.nil? || name.empty?
        add_error(:text, :must_be_present) if text.nil? || text.empty?
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
        representation = attributes
        representation.merge!(errors: errors) unless valid?
        representation.to_json(*args)
      end

      def attributes
        Hash[ATTRIBUTES.map { |key| [key, self.send(key)] }]
      end

      def fetch
        set_attributes(Comment.repository.fetch(id))
        self
      end

      def sync
        validate!
        Comment.repository.store(id, attributes)
        self
      end

      def delete
        Comment.repository.delete(id)
        self
      end

      private

      attr_writer :errors, :id, :url, :name, :text, :created_at

      def next_id
        SecureRandom.uuid
      end

      def set_attributes(attributes={})
        attributes
          .select { |key, value| ATTRIBUTES.include?(key.to_sym) }
          .each { |key, value| self.send("#{key}=", value) }
      end

      def add_error(attribute, error)
        errors[attribute] = (errors[attribute] || []).push(error)
      end
    end # Member
  end # Comment
end # Blabber

