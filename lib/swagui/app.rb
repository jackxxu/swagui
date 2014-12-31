require 'rack'
require 'json'
require 'yaml'
require 'rack/cors'

module Swagui

  class App

    CORS_SETTING_PROC = Proc.new {
      allow do
        origins '*'
        resource '*',
          :headers => :any,
          :methods => [:get, :post, :put, :delete, :options]
      end
    }.freeze

    def initialize(app, options={}, &blk)
      @app = app
      @asset_handler = AssetHandler.new(options[:url])
      @swagger_doc_handler = SwaggerDocHandler.new(options[:path], options[:url])

      if block_given?
        @asset_stack = Rack::Auth::Basic.new(@asset_handler, "Restricted Documentation", &blk)
        @swagger_doc_stack = Rack::Cors.new(Rack::Auth::Basic.new(@swagger_doc_handler, "Restricted Documentation", &blk), &CORS_SETTING_PROC)
      else
        @asset_stack = @asset_handler
        @swagger_doc_stack = Rack::Cors.new(@swagger_doc_handler, &CORS_SETTING_PROC)
      end
    end

    def call(env)
      if @asset_handler.handles?(env) # for assets (css/js) files
        @asset_stack.call(env)
      elsif @swagger_doc_handler.handles?(env) # for swagger json files
        @swagger_doc_stack.call(env)
      else
        @app.call(env)
      end
    end
  end
end
