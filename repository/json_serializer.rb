# encoding: utf-8
require 'json'
require 'fileutils'

module Blabber
  module Repository
    class JsonSerializer
      def initialize(basedir)
        @basedir = basedir
      end

      def store(id, data)
        File.open(File.join(basedir, id), 'w') { |file|
          file << data.to_hash.to_json
        }
      end

      def fetch(id)
        JSON.parse(File.read(File.join(basedir, id)))
      rescue Errno::ENOENT
        raise KeyError
      end

      def delete(id)
        File.delete(File.join(basedir, id))
      end

      def apply(id, operations)
        operations.each { |operation|
          command, args = operation[0], operation[1..-1]
          self.send(command, id, *args)
        }
      end

      def add(id, *members)
        path = File.join(basedir, id)
        data = JSON.parse(json_from(path) || [].to_json).push(*members)
        File.open(path, 'w') { |file| file << data.to_json }
      end

      def remove(id, *members)
        path = File.join(basedir, id)
        data = JSON.parse(json_from(path) || [].to_json)

        members.each { |member| data.delete(member) }
        (File.delete(path) && return) if data.empty?

        File.open(path, 'w') { |file| file << data.to_json }
      end

      alias_method :clear, :delete

      def flush
        FileUtils.rm_rf(Dir.glob("#{basedir}/*"))
      end

      private 

      attr_reader :basedir

      def json_from(path)
        File.exists?(path) and File.read(path)
      end
    end # JsonSerializer
  end # Repository
end # Blabber

