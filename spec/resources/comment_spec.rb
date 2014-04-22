# encoding: utf-8
require 'minitest/autorun'
require_relative '../../resources/comment'

include Blabber

describe '#repository=' do
  it 'accepts a single object as repository for members and collections' do
    Comment.repository = "memory"
    Comment.repository.must_equal "memory"
  end

  it 'accepts tuple of repositories for members and collections' do
    Comment.repository = ["member", "collection"]
    Comment.repository(:member).must_equal "member"
    Comment.repository(:collection).must_equal "collection"
    Comment.repository.must_equal "member"
  end
end

