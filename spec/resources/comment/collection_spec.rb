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
      member = Minitest::Mock.new
      member.expect :hash, rand(999)
      member.expect :validate!, member

      collection = Comment::Collection.new('test')
      collection.add(member)
      member.verify
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
        [:add, comment1],
        [:add, comment2],
        [:remove, comment1],
        [:remove, comment2],
        [:add, comment2],
        [:clear]
      ]

      repository = Minitest::Mock.new
      Comment.repository = repository

      repository.expect :apply, repository, [collection.id, operations]
      collection.sync
      repository.verify
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

