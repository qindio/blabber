# encoding: utf-8
require 'minitest/autorun'
require_relative '../../api'

describe Blabber::Helpers do
  before do
    @klass = Class.new do 
      attr_accessor :session, :request
      include Blabber::Helpers
    end
  end

  describe '#payload' do
    it 'returns a parsed JSON payload' do
      testbed = @klass.new
      testbed.request = Rack::Request.new(
        "rack.input" => StringIO.new({ "foo" => "bar" }.to_json)
      )
      testbed.payload.must_equal({"foo" => "bar" })
    end
  end

  describe '#admin?' do
    it 'returns true if current user id is an admin' do
      testbed = @klass.new

      testbed.session = { "user_id" => Blabber::Api::ADMIN_ID }
      testbed.admin?.must_equal true

      testbed.session["user_id"] = 0
      testbed.admin?.must_equal false
    end
  end

  describe '#admin_match?' do
    it "returns true if passed credentials match admin's" do
      testbed = @klass.new
      testbed.admin_match?(Blabber::Api::ADMIN_CREDENTIALS).must_equal true

      testbed.admin_match?(Blabber::Api::ADMIN_CREDENTIALS).must_equal true
      testbed.admin_match?({}).must_equal false
    end
  end
end

