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
        overwrite_data_in(File.join(basedir, id)) { |data|
          operations.each { |operation|
            command, args = operation[0], operation[1..-1]
            self.send(command, false, *args).call(data)
          }
        }
      end

      def add(id, *members)
        transformation = lambda { |data| data.push(*members) }
        return transformation unless id

        overwrite_data_in(File.join(basedir, id), &transformation) 
      end

      def remove(id, *members)
        transformation = lambda { |data| 
          members.each { |member| data.delete(member) }
        }
        return transformation unless id

        overwrite_data_in(File.join(basedir, id), &transformation)
      end

      alias_method :clear, :delete

      def flush
        FileUtils.rm_rf(Dir.glob("#{basedir}/*"))
      end

      private 

      attr_reader :basedir

      def overwrite_data_in(path, &block)
        data = JSON.parse(json_from(path) || [].to_json)

        block.call(data)

        File.delete(path) and return self if data.empty?
        File.open(path, 'w') { |file| file << data.to_json }
        self
      end

      def json_from(path)
        File.exists?(path) and File.read(path)
      end
    end # JsonSerializer
  end # Repository
end # Blabber

