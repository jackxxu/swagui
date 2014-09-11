require 'rack'
require 'json'
require 'yaml'

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
      if @assets_url_regex.match(path) # for assets (css/js) files
        env["PATH_INFO"] = path.gsub(@assets_url_regex, '')
        @swagger_ui_file_server.call(env)
      elsif @url_regex.match(path)
        path = path.gsub(@url_regex, '') # root path renders index.html
        if path == '' || path == '/'
          env["PATH_INFO"] = 'index.html'
          @swagger_ui_file_server.call(env)
        else

          env['HTTP_IF_MODIFIED_SINCE'] = nil # not 304s

          response = [404, {"Content-Type"=>"application/json"}, '']
          extension = ['', '.json', '.yml'].find do |ext|
            response = @app_file_server.call(env.dup.merge!('PATH_INFO' => "#{path}#{ext}"))
            response[0] == 200
          end

          # handles yaml parsing
          if extension == '.yml'
            body = ''
            response[2].each {|f| body = YAML::load(f).to_json}
            response[2] = [body]
            response[1].merge!("Content-Length"=> body.size.to_s)
          end

          response[1].merge!("Content-Type"=>"application/json") # response is always json content

          response
        end
      else
        @app.call(env)
      end
    end
  end
end
