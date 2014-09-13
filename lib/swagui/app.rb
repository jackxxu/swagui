require 'rack'
require 'json'
require 'yaml'

module Swagui

  class App

    def initialize(app, options={}, &blk)
      @app = app
      @asset_handler = AssetHandler.new(options[:url])
      @swagger_doc_handler = SwaggerDocHandler.new(options[:path], options[:url])

      if block_given?
        @asset_stack = Rack::Auth::Basic.new(@asset_handler, "Restricted Documentation", &blk)
        @swagger_doc_stack = Rack::Auth::Basic.new(@swagger_doc_handler, "Restricted Documentation", &blk)
      else
        @asset_stack = @asset_handler
        @swagger_doc_stack = @swagger_doc_handler
      end
    end

    def call(env)
      if @asset_handler.handles?(env) # for assets (css/js) files
        @asset_stack.call(env)
      elsif @swagger_doc_handler.handles?(env) # for assets (css/js) files
        @swagger_doc_stack.call(env)
      else
        @app.call(env)
      end
    end
  end
end
