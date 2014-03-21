# encoding: utf-8
require 'minitest/autorun'
require 'rack/test'
require 'json'

require_relative '../../api'

def app
  Blabber::Api.new
end

describe Blabber::Api do
  include Rack::Test::Methods

  before do
    @headers = { "CONTENT_TYPE" => "application/json" }
    Blabber::Comment.repository.flush
  end

  describe 'post /comments' do
    it 'creates a comment' do
      comment = fixture

      post "/comments", comment.to_json, @headers
      last_response.status.must_equal 201

      response = JSON.parse(last_response.body)
      response.fetch("id").wont_be_empty
      response.fetch("name").must_equal comment.fetch(:name)
    end

    it 'puts the comment in a pending state, awaiting approval' do
      comment = fixture

      post "/comments", comment.to_json, @headers
      last_response.status.must_equal 201
      comment_id = JSON.parse(last_response.body).fetch('id')
      
      get "/comments/pending"
      last_response.status.must_equal 200

      response = JSON.parse(last_response.body)
      response.map { |comment|
        comment.fetch('id')
      }.must_include(comment_id)
    end

    it 'returns 400 if comment invalid' do
      comment = { name: 'John Doe' }

      post "/comments", comment.to_json, @headers
      last_response.status.must_equal 400
      JSON.parse(last_response.body).fetch("errors").wont_be_empty
    end
  end

  describe 'get /comments/:comment_id' do
    it 'retrieves a comment' do
      comment = fixture
      post "/comments", comment.to_json, @headers

      comment_id = JSON.parse(last_response.body).fetch("id")
      get "/comments/#{comment_id}"

      last_response.status.must_equal 200
      response = JSON.parse(last_response.body)

      response.fetch("id").must_equal comment_id
      response.fetch("name").must_equal fixture.fetch(:name)
    end

    it 'returns 404 if comment does not exist' do
      get "/comments/nonexistent"
      last_response.status.must_equal 404
      last_response.body.must_be_empty
    end
  end

  describe 'get /comments/?url=url' do
    it 'returns comments linked to the url' do
      comment = fixture
      post "/comments", comment.to_json, @headers

      comment_id = JSON.parse(last_response.body).fetch("id")
      url = CGI.escape(comment.fetch(:url))

      get "/comments?url=#{url}"
      JSON.parse(last_response.body).must_be_empty
    end
  end

  describe 'get /comments' do
    it 'returns 204 if no url passed as a param' do
      get "/comments"
      last_response.status.must_equal 204
    end
  end

  describe 'put /comments/approved/:comment_id' do
    it 'makes the comment visible for the url' do
      comment = fixture
      post "/comments", comment.to_json, @headers

      comment_id = JSON.parse(last_response.body).fetch("id")

      get "/comments?url=#{comment.fetch(:url)}"
      JSON.parse(last_response.body).must_be_empty

      put "/comments/approved/#{comment_id}",
        comment.to_json, @headers
      last_response.status.must_equal 200

      get "/comments?url=#{comment.fetch(:url)}"
      JSON.parse(last_response.body).first.fetch("id")
        .must_equal comment_id
    end
  end

  describe 'delete /comments/:comment_id' do
    it 'removes a comment' do
      comment = fixture
      post "/comments", comment.to_json, @headers

      comment_id = JSON.parse(last_response.body).fetch("id")

      get "/comments/#{comment_id}"
      last_response.status.must_equal 200

      delete "/comments/#{comment_id}"
      last_response.status.must_equal 204

      get "/comments/#{comment_id}"
      last_response.status.must_equal 404
    end

    it 'removes the comment from the pending collection' do
      comment = fixture
      post "/comments", comment.to_json, @headers

      comment_id = JSON.parse(last_response.body).fetch("id")

      get "/comments/pending"
      JSON.parse(last_response.body).map { |comment|
        comment.fetch("id")
      }.must_include comment_id

      delete "/comments/#{comment_id}"

      get "/comments/pending"
      JSON.parse(last_response.body).map { |comment|
        comment.fetch("id")
      }.wont_include comment_id
    end

    it 'removes the comment from collection linked to its url' do
      comment = fixture
      post "/comments", comment.to_json, @headers
      comment_id = JSON.parse(last_response.body).fetch("id")

      put "/comments/approved/#{comment_id}",
        comment.to_json, @headers
      last_response.status.must_equal 200

      get "/comments?url=#{comment.fetch(:url)}"
      JSON.parse(last_response.body).first.fetch("id").must_equal comment_id

      delete "/comments/#{comment_id}"

      get "/comments?url=#{comment.fetch(:url)}"
      JSON.parse(last_response.body).must_be_empty
    end
  end

  def fixture
    {
      name: "John Doe",
      text: "Awesome post!",
      url: "http://example.com/post/1"
    }
  end
end # Blabber::Api
