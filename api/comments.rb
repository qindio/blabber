# encoding: utf-8
require 'sinatra/base'
require_relative './helpers'
require_relative '../resources/comment'

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
      entry = Comment.entry_from(CGI.unescape(params[:url]))

      begin
        comments = Comment::Collection.new("comments:#{entry}").fetch
          .sort_by { |comment| comment.created_at }
        [200, comments.to_json]
      rescue ResourceNotFound
        [200, [].to_json]
      end
    end

    get "/comments/pending" do
      begin
        comments = Comment::Collection.new("comments:pending").fetch
          .sort_by { |comment| comment.created_at }
        [200, comments.to_json]
      rescue ResourceNotFound
        [200, [].to_json]
      end
    end

    put "/comments/approved/:comment_id" do
      return [401] unless admin?

      begin
        comment = Comment::Member.new(id: params[:comment_id]).fetch
        pending_comments = Comment::Collection.new("comments:pending")
        entry_comments = Comment::Collection.new("comments:#{comment.entry}")

        pending_comments.remove(comment).sync
        entry_comments.add(comment).sync

        [200, comment.to_json]
      rescue ResourceNotFound
        [404]
      end
    end

    get "/comments/:comment_id" do
      begin
        comment = Comment::Member.new(id: params[:comment_id]).fetch
        [200, comment.to_json]
      rescue ResourceNotFound
        [404]
      end
    end

    delete "/comments/:comment_id" do
      return [401] unless admin?

      begin
        comment = Comment::Member.new(id: params[:comment_id]).fetch
        pending_comments = Comment::Collection.new("comments:pending")
        entry_comments = Comment::Collection.new("comments:#{comment.entry}")
      
        pending_comments.remove(comment).sync
        entry_comments.remove(comment).sync
        comment.delete
        [204]
      rescue ResourceNotFound
        [404]
      end
    end
  end # Api
end # Blabber

