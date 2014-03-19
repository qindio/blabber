# encoding: utf-8
require 'minitest/autorun'
require 'securerandom'

require_relative '../../repository/memory'

include Blabber

describe Repository::Memory do
  describe '#store' do
    it 'persists member data using the passed id as key' do
      member = fixture_member
      repository = Repository::Memory.new

      lambda { repository.fetch("test") }.must_raise KeyError

      repository = Repository::Memory.new
      repository.store("test", member)
      repository.fetch("test").must_equal member
    end
  end

  describe '#fetch' do
    it 'returns member data for a member id' do
      member = fixture_member
      repository = Repository::Memory.new
      repository.store("test", member)

      repository.fetch("test").must_equal(member)
    end

    it 'raises KeyError if member cannot be found' do
      repository = Repository::Memory.new
      lambda { repository.fetch("nonexistent") }.must_raise KeyError
    end
  end

  describe '#delete' do
    it 'deletes the member, removing the key' do
      member = fixture_member
      repository = Repository::Memory.new

      repository.store("test", member)
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
      repository.add("collection-1", fixture_member)
      repository.fetch("collection-1").wont_be_empty
    end
  end

  describe '#remove' do
    it 'removes a member from a collection' do
      members = (1..5).map { |t| fixture_member }

      repository = Repository::Memory.new
      repository.add("collection-1", members.at(1))
      repository.fetch("collection-1").wont_be_empty

      repository.remove("collection-1", members.at(1))
      repository.fetch("collection-1").must_be_empty

      members_with_repetition = members[1..4].push(members.at(1))

      repository.add("collection-1", *members_with_repetition)
      repository.fetch("collection-1").wont_be_empty
      repository.remove("collection-1", *members_with_repetition)
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

  describe '#flush' do
    it 'removes all data from the repository' do
      repository = Repository::Memory.new
      member1 = { id: 1 }
      member2 = { id: 2 }

      repository.store(member1.fetch(:id), member1)
      repository.store(member2.fetch(:id), member1)
      repository.apply("collection-1", [["add", member1], ["add", member2]])

      repository.flush
      lambda { repository.fetch(member1.fetch(:id)) }.must_raise KeyError
      lambda { repository.fetch(member2.fetch(:id)) }.must_raise KeyError
      lambda { repository.fetch("collection-1") }.must_raise KeyError
    end
  end

  def fixture_member
    member_klass = Struct.new(:id, :name, :email)
    member_klass.new(
      id: SecureRandom.uuid,
      name: 'foo',
      email: 'foo@foo.com' 
    )
  end
end

