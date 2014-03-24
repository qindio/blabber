# encoding: utf-8
require 'minitest/autorun'
require 'fileutils'
require 'securerandom'
require_relative '../../repository/json_serializer'

include Blabber

describe Repository::JsonSerializer do
  before do
    @basedir = "/var/tmp/test-#{Time.now.to_f}"
    FileUtils.mkdir(@basedir)
    @repository = Repository::JsonSerializer.new(@basedir)
  end

  after do
    FileUtils.rm_r(@basedir)
  end

  describe '#store' do
    it 'persists member data using the passed id as key' do
      member = fixture_member
      File.exists?(File.join("#{@basedir}/#{member.fetch('id')}"))
        .must_equal false

      @repository.store(member.fetch('id'), member)
      File.exists?(File.join("#{@basedir}/#{member.fetch('id')}"))
        .must_equal true
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

  describe '#apply' do
    it 'executes a list of operations on a collection' do
      @repository.apply("collection-1", [["add", "1"], ["add", "2"]])
      @repository.fetch("collection-1").wont_be_empty
    end
  end

  describe '#add' do
    it 'returns a block for the applicable transformation if no id passed' do
      block = @repository.add(nil, fixture_member)
      block.class.must_equal Proc

      collection = []
      collection.must_be_empty
      block.call(collection)
      collection.wont_be_empty
    end

    it 'adds a member to a collection' do
      lambda { @repository.fetch("collection-test") }.must_raise KeyError 
      @repository.add("collection-test", fixture_member)
      @repository.fetch("collection-test").wont_be_empty
    end

    it 'creates a collection on the key if does not exist' do
      File.exists?(File.join(@basedir, "collection-test")).must_equal false
      @repository.add("collection-test", fixture_member)
      File.exists?(File.join(@basedir, "collection-test")).must_equal true
    end
  end

  describe '#remove' do
    it 'returns a block for the applicable transformation if no id passed' do
      member = fixture_member
      collection = [member]

      block = @repository.remove(nil, member)
      block.class.must_equal Proc

      collection.wont_be_empty
      block.call(collection)
      collection.must_be_empty
    end

    it 'removes a member from a collection' do
      member1 = fixture_member
      member2 = fixture_member

      @repository.add("collection-test", member1)
      @repository.fetch("collection-test").wont_be_empty
      @repository.add("collection-test", member2)

      @repository.remove("collection-test", member1)
      @repository.fetch("collection-test").wont_include(member1)
    end

    it 'deletes the key of the collection if empty' do
      member = fixture_member

      @repository.add("collection-test", member)
      File.exists?(File.join(@basedir, "collection-test")).must_equal true

      @repository.remove("collection-test", member)
      File.exists?(File.join(@basedir, "collection-test")).must_equal false
    end
  end

  describe '#clear' do
    it 'deletes the collection, removing the key' do
      @repository.apply("collection-test", [["add", "1"], ["add", "2"]])
      @repository.fetch("collection-test").wont_be_empty
      @repository.clear("collection-test")
      lambda { @repository.fetch("collection-1") }.must_raise KeyError
    end
  end

  describe '#flush' do
    it 'removes all data from the repository' do
      member = fixture_member

      @repository.add("collection-test", member)
      @repository.store(member.fetch("id"), member)

      File.exists?(File.join(@basedir, "collection-test")).must_equal true
      File.exists?(File.join(@basedir, member.fetch("id"))).must_equal true

      @repository.flush
      File.exists?(File.join(@basedir, "collection-test")).must_equal false
      File.exists?(File.join(@basedir, member.fetch("id"))).must_equal false
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

