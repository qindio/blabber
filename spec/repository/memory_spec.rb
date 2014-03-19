# encoding: utf-8
require 'minitest/autorun'
require 'securerandom'
require 'json'

require_relative '../../repository/memory'

include Blabber

describe Repository::Memory do
  describe '#store' do
    it 'persists member data using the passed id as key' do
      member = fixture
      repository = Repository::Memory.new

      lambda { repository.fetch("test") }.must_raise KeyError

      repository = Repository::Memory.new
      repository.store("test", member.to_json)
      repository.fetch("test").must_equal member.to_json
    end
  end

  describe '#fetch' do
    it 'returns member data for a member id' do
      member = fixture
      repository = Repository::Memory.new
      repository.store("test", member.to_json)

      repository.fetch("test").must_equal(member.to_json)
    end

    it 'raises KeyError if member cannot be found' do
      repository = Repository::Memory.new
      lambda { repository.fetch("nonexistent") }.must_raise KeyError
    end
  end

  describe '#delete' do
    it 'deletes the member, removing the key' do
      member = fixture
      repository = Repository::Memory.new

      repository.store("test", member.to_json)
      repository.fetch("test").wont_be_nil

      repository.delete("test")
      lambda { repository.fetch("test") }.must_raise KeyError
    end
  end

  describe '#apply' do
    it 'creates a collection on the key if it does not exist' do
      repository = Repository::Memory.new
      lambda { repository.fetch("collection-1") }.must_raise KeyError
      repository.apply("collection-1", [["add", "1"]])
      repository.fetch("collection-1").wont_be_empty
    end

    it 'executes a list of operations on a collection' do
      repository = Repository::Memory.new
      repository.apply("collection-1", [["add", "1"], ["add", "2"]])
      repository.fetch("collection-1").wont_be_empty
    end
  end

  describe '#add' do
    it 'adds a member to a collection' do
      repository = Repository::Memory.new
      lambda { repository.fetch("collection-1") }.must_raise KeyError
      repository.add("collection-1", 1)
      repository.fetch("collection-1").wont_be_empty
    end
  end

  describe '#remove' do
    it 'removes a member from a collection' do
      repository = Repository::Memory.new
      repository.add("collection-1", 1)
      repository.fetch("collection-1").wont_be_empty

      repository.remove("collection-1", 1)
      repository.fetch("collection-1").must_be_empty

      repository.add("collection-1", 1, 2, 3, 4, 1)
      repository.fetch("collection-1").wont_be_empty
      repository.remove("collection-1", 1, 2, 3, 4)
      repository.fetch("collection-1").must_be_empty
    end
  end

  describe '#clear' do
    it 'deletes the collection, removing the key' do
      repository = Repository::Memory.new
      repository.apply("collection-1", [["add", "1"], ["add", "2"]])
      repository.fetch("collection-1").wont_be_empty
      repository.clear("collection-1")
      lambda { repository.fetch("collection-1") }.must_raise KeyError
    end
  end

  def fixture
    { 
      id: SecureRandom.uuid,
      name: 'foo',
      email: 'foo@foo.com' 
    }
  end
end

