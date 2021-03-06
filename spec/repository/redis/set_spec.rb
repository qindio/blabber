# encoding: utf-8
require 'minitest/autorun'
require 'securerandom'
require 'redis'
require 'linemanager'
require_relative '../../../repository/redis/set'

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
    @repository = Repository::Redis::Set.new(connection)
  end

  after do
    @manager.teardown
  end

  describe '#apply' do
    it 'executes a list of operations on a collection' do
      member1, member2 = fixture_member, fixture_member
      @repository.apply("collection-1", [["add", member1], ["add", member2]])
      @repository.fetch("collection-1").wont_be_empty
      @repository.apply("collection-1", [["remove", member1], ["remove", member2]])
      lambda { @repository.fetch("collection-1") }.must_raise KeyError
    end
  end

  describe '#add' do
    it 'adds a member to a collection' do
      lambda { @repository.fetch("collection-test") }.must_raise KeyError
      @repository.add("collection-test", fixture_member, fixture_member)
      @repository.fetch("collection-test").wont_be_empty
    end

    it 'creates a collection on the key if does not exist' do
      @repository.add("collection-test", fixture_member)
    end
  end

  describe '#remove' do
    it 'removes a member from a collection' do
      member1 = fixture_member
      member2 = fixture_member

      @repository.add("collection-test", member1)
      @repository.fetch("collection-test").wont_be_empty
      @repository.add("collection-test", member2)

      @repository.remove("collection-test", member1)
      @repository.fetch("collection-test").wont_include(member1)
      @repository.fetch("collection-test").must_include(member2)
    end

    it 'deletes the key of the collection if empty' do
      member = fixture_member

      @repository.add("collection-test", member)
      @repository.remove("collection-test", member)
      lambda { @repository.fetch("collection-test") }.must_raise KeyError
    end
  end

  describe '#clear' do
    it 'empties the collection' do
      @repository.apply("collection-test", [["add", fixture_member], ["add", fixture_member]])
      @repository.fetch("collection-test").wont_be_empty
      @repository.clear("collection-test")
      lambda { @repository.fetch("collection-1") }.must_raise KeyError
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

