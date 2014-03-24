# encoding: utf-8
require 'minitest/autorun'
require_relative '../../../resources/comment/collection'
require_relative '../../../resources/comment/member'

include Blabber

describe Comment::Collection do
  describe '#id' do
    it 'returns the id passed at initialization' do
      lambda { Comment::Collection.new }.must_raise ArgumentError
      Comment::Collection.new("test").id.must_equal "test"
    end
  end

  describe '#add' do
    it 'adds a member' do
      collection = Comment::Collection.new('test')
      collection.empty?.must_equal true

      collection.add(new_comment)
      collection.empty?.must_equal false
    end

    it 'validates the member' do
      member_fake = Class.new {
        attr_reader :validate_called
        def validate!; @validate_called = true; end
        def attributes; {}; end
      }.new

      collection = Comment::Collection.new('test')
      collection.add(member_fake)
      member_fake.validate_called.must_equal true
    end
  end

  describe '#remove' do
    it 'removes a member from the collection' do
      collection = Comment::Collection.new('test')
      collection.empty?.must_equal true
      comment = new_comment

      collection.add(comment)
      collection.empty?.must_equal false

      collection.remove(comment)
      collection.empty?.must_equal true
    end
  end

  describe '#clear' do
    it 'empties the collection' do
      collection = Comment::Collection.new('test')
      collection.add(new_comment)
      collection.empty?.must_equal false

      collection.clear
      collection.empty?.must_equal true
    end
  end

  describe '#empty?' do
    it 'returns true if no members loaded' do
      collection = Comment::Collection.new('test')
      collection.empty?.must_equal true
    end

    it 'returns false otherwise' do
      collection = Comment::Collection.new('test')
      collection.empty?.must_equal true
      collection.add(new_comment)
      collection.empty?.must_equal false
    end
  end

  describe '#sync' do
    it 'tells the repository to apply a backlog of operations
    on the collection' do
      collection = Comment::Collection.new('test')
      comment1, comment2 = new_comment, new_comment

      collection.add(comment1)
      collection.add(comment2)
      collection.remove(comment1)
      collection.remove(comment2)
      collection.add(comment2)
      collection.clear

      operations = [
        [:add, comment1.attributes],
        [:add, comment2.attributes],
        [:remove, comment1.attributes],
        [:remove, comment2.attributes],
        [:add, comment2.attributes],
        [:clear]
      ]

      repository = Minitest::Mock.new
      Comment.repository = repository

      repository.expect :apply, repository, [collection.id, operations]
      collection.sync
      repository.verify
    end
  end

  describe '#fetch' do
    it 'resets the collection with member data from the repository' do
      fake_repository = Object.new
      def fake_repository.fetch(*args)
        [{ name: 'name 1', text: 'text 1' }]
      end

      Comment.repository = fake_repository

      collection = Comment::Collection.new('test')
      collection.must_be_empty

      collection.fetch
      collection.to_a.length.must_equal 1
      collection.first.name.must_equal 'name 1'
    end
  end

  describe '#each' do
    it 'yields members in the collection' do
      collection = Comment::Collection.new('test')
      collection.add(new_comment)
      collection.add(new_comment)

      collection.to_a.length.must_equal 2
    end
  end

  describe '#to_json' do
    it 'returns a JSON representation of the collection' do
      collection = Comment::Collection.new('test')
      collection.add(new_comment)
      collection.add(new_comment)

      collection.to_a.first
      JSON.parse(collection.to_json).length.must_equal 2
    end
  end

  def new_comment
    Comment::Member.new(
      name: "name #{Time.now.to_f}",
      text: "text #{Time.now.to_f}",
      url: "www.example.com"
    )
  end
end

