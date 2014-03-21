# encoding: utf-8
require 'sinatra/base'
require_relative '../resources/comment/comment'

module Blabber
  class Api < Sinatra::Base
    post "/comments" do
      begin
        comment = Comment::Member.new(payload)
        pending_comments = Comment::Collection.new("comments:pending")
        pending_comments.add(comment)

        comment.sync
        pending_comments.sync

        [201, comment.to_json]
      rescue InvalidResource
        [400, comment.to_json]
      end
    end

    get "/comments" do
      return [204] unless params[:url]

      uri = URI(CGI.unescape(params[:url]))
      page = uri.to_s.split([uri.scheme, '://'].join).last

      begin
        comments = Comment::Collection.new("comments:#{page}").fetch
        [200, comments.to_json]
      rescue KeyError
        [200, [].to_json]
      end
    end

    get "/comments/pending" do
      begin
        comments = Comment::Collection.new("comments:pending").fetch
        [200, comments.to_json]
      rescue KeyError
        [200, [].to_json]
      end
    end

    put "/comments/approved/:comment_id" do
      begin
        comment = Comment::Member.new(id: params[:comment_id]).fetch
        pending_comments = Comment::Collection.new("comments:pending")
        page_comments = Comment::Collection.new("comments:#{comment.page}")

        pending_comments.remove(comment).sync
        page_comments.add(comment).sync

        [200, comment.to_json]
      rescue KeyError
        [404]
      end
    end

    get "/comments/:comment_id" do
      begin
        comment = Comment::Member.new(id: params[:comment_id]).fetch
        [200, comment.to_json]
      rescue KeyError
        [404]
      end
    end

    delete "/comments/:comment_id" do
      begin
        comment = Comment::Member.new(id: params[:comment_id]).fetch
        pending_comments = Comment::Collection.new("comments:pending")
        page_comments = Comment::Collection.new("comments:#{comment.page}")
      
        pending_comments.remove(comment).sync
        page_comments.remove(comment).sync
        comment.delete
        [204]
      rescue KeyError
        [404]
      end
    end
  end # Api
end # Blabber


