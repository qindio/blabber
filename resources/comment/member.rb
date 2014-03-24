# encoding: utf-8
require 'securerandom'
require 'json'
require 'uri'
require 'time'
require_relative './module'
require_relative '../exceptions'

module Blabber
  module Comment
    class Member
      ATTRIBUTES = [:id, :url, :name, :text, :created_at]

      attr_reader :errors, :id, :url, :name, :text, :created_at

      def initialize(attributes={})
        set_attributes(attributes)
        @id ||= next_id
        @created_at ||= Time.now.utc
        @errors = {}
      end

      def created_at=(time_as_object_or_string)
        @created_at = Time.parse(time_as_object_or_string.to_s).utc
      end

      def entry
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
        @attributes = Hash[ATTRIBUTES.map { |key| [key, self.send(key)] }]
        @attributes.store(
          :created_at, @attributes.fetch(:created_at).utc.iso8601
        )
        @attributes
      end

      def fetch
        set_attributes(Comment.repository.fetch(id))
        self
      rescue KeyError, Errno::ENOENT
        raise ResourceNotFound
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

      attr_writer :errors, :id, :url, :name, :text

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

