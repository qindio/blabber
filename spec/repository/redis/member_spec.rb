# encoding: utf-8
require 'minitest/autorun'
require 'securerandom'
require 'redis'
require 'linemanager'
require_relative '../../../repository/redis/member'

include Blabber

describe Repository::Redis do
  before do
    app_dir = File.expand_path(
      File.join(File.dirname(__FILE__), '..', '..', '..')
    )

    @manager = LineManager::Runner.new(app_dir, 'test')
    @manager.wait_for('Server started, Redis')

    connection = Redis.new(port: ENV['REDIS_PORT'])
    connection.flushdb
    @repository = Repository::Redis::Member.new(connection)
  end

  after do
    @manager.teardown
  end

  describe '#store' do
    it 'persists member data using the passed id as key' do
      member = fixture_member
      lambda { @repository.fetch("test") }.must_raise KeyError

      @repository.store("test", member)
      @repository.fetch("test").must_equal member.to_hash
    end
  end

  describe '#fetch' do
    it 'returns member data for a member id' do
      member = fixture_member
      @repository.store(member.fetch('id'), member)
      @repository.fetch(member.fetch('id')).must_equal member.to_hash
    end

    it 'raises KeyError if member cannot be found' do
      lambda { @repository.fetch("nonexistent") }.must_raise KeyError
    end
  end

  describe '#delete' do
    it 'deletes the member, removing the key' do
      member = fixture_member
      @repository.store(member.fetch('id'), member)
      @repository.fetch(member.fetch('id')).must_equal member.to_hash
      @repository.delete(member.fetch('id'))

      lambda { @repository.fetch(member.fetch('id')) }
        .must_raise KeyError
    end
  end

  def fixture_member
    {
      "id"    => SecureRandom.uuid,
      "name"  => 'foo',
      "email" => 'foo@foo.com'
    }
  end
end

