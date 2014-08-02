require 'rack'

module Swagui

  class Middleware

    def initialize(app, options={})
      @app = app

      @url_path = options[:url]
      @doc_path = options[:path] || @url_path
      @url_regex = Regexp.new("^#{@url_path}")
      @assets_url_regex = Regexp.new("^\/swagger-ui")

      app_doc_dir = File.expand_path(@doc_path, Dir.pwd)
      @app_file_server = Rack::File.new(app_doc_dir)
      swagger_ui_dir = File.expand_path('../../swagger-ui', File.dirname(__FILE__))
      @swagger_ui_file_server = Rack::File.new(swagger_ui_dir)
    end

    def call(env)
      path = env["PATH_INFO"].strip

      if @assets_url_regex.match(path)
        env["PATH_INFO"] = path.gsub(@assets_url_regex, '')
        @swagger_ui_file_server.call(env)
      elsif @url_regex.match(path)
        path = path.gsub(@url_regex, '')
        if path == '' || path == '/'
          env["PATH_INFO"] = 'index.html'
          @swagger_ui_file_server.call(env)
        else
          env["PATH_INFO"] = path
          @app_file_server.call(env)
        end
      else
        @app.call(env)
      end
    end
  end
end
