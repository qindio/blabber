# encoding: utf-8
require 'minitest/autorun'
require 'securerandom'
require_relative '../../../resources/comment/member'

include Blabber

describe Comment::Member do
  describe '#id' do
    it "is generated a UUID if not passed at initialization" do
      Comment::Member.new.id.wont_be_empty

      id = SecureRandom.uuid
      Comment::Member.new(id: id).id.must_equal id
    end
  end

  describe '#created_at' do
    it 'is generated if not passed at initalization' do
      Comment::Member.new.created_at.must_be_instance_of Time

      created_at = Time.now
      Comment::Member.new(created_at: created_at).created_at
        .must_equal created_at
    end
  end

  describe '#validate' do
    it 'requires a name' do
      comment = Comment::Member.new
      comment.validate
      comment.errors.fetch(:name).must_include(:must_be_present)

      comment = Comment::Member.new(name: 'foo')
      comment.validate
      comment.errors.fetch(:name).must_be_empty
    end

    it 'requires some text' do
      comment = Comment::Member.new
      comment.validate
      comment.errors.fetch(:text).must_include(:must_be_present)

      comment = Comment::Member.new(text: 'foo')
      comment.validate
      comment.errors.fetch(:text).must_be_empty
    end
  end

  describe '#validate!' do
    it 'raises InvalidResource if resource invalid' do
      lambda { Comment::Member.new.validate! }.must_raise InvalidResource
      comment = Comment::Member.new(name: 'foo', text: 'bar').validate!
    end
  end

  describe '#valid?' do
    it 'returns false if any attribute has any errors' do
      comment = Comment::Member.new.validate
      comment.valid?.must_equal false

      comment = Comment::Member.new(name: 'foo').validate
      comment.valid?.must_equal false

      comment = Comment::Member.new(text: 'foo').validate
      comment.valid?.must_equal false
    end

    it 'returns true if there are no validation errors' do
      comment = Comment::Member.new(name: 'foo', text: 'bar').validate
      comment.valid?.must_equal true
    end
  end

  describe '#attributes' do
    it 'returns an attributes hash for the resource' do
      comment = Comment::Member.new(name: 'foo', text: 'bar')
      comment.attributes.keys.sort.must_equal Comment::Member::ATTRIBUTES.sort

      comment.attributes.fetch(:name).must_equal 'foo'
      comment.attributes.fetch(:text).must_equal 'bar'
    end
  end

  describe '#to_json' do
    it 'returns a JSON representation of resource attributes' do
      comment = Comment::Member.new(name: 'foo', text: 'bar')
      JSON.parse(comment.to_json).fetch("name").must_equal comment.name
      JSON.parse(comment.to_json).fetch("text").must_equal comment.text
    end
  end

  describe '#fetch' do
    it 'retrieves attributes from the repository' do
      fake_repository = Object.new
      def fake_repository.fetch(*args)
        { name: 'name 1', text: 'text 1' }.to_json
      end

      Comment.repository = fake_repository
      comment = Comment::Member.new

      comment.name.must_be_nil
      comment.fetch
      comment.name.must_equal 'name 1'
    end
  end

  describe '#sync' do
    it 'raises InvalidResource if resource invalid' do
      lambda { Comment::Member.new.sync }.must_raise InvalidResource
    end

    it 'tells the repository to store the resource' do
      attributes = { name: 'foo', text: 'bar' }
      repository = MiniTest::Mock.new
      Comment.repository = repository

      comment = Comment::Member.new(attributes)
      repository.expect :store, repository, [comment.id, comment.to_json]

      comment.sync
      repository.verify
    end
  end
end # Comment::Member

