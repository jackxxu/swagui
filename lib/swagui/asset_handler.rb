module Swagui
  class AssetHandler

    def initialize(path)
      @url_regex = Regexp.union(Regexp.new("^\/swagger-ui"), Regexp.new("^#{path}\/?$"))
      swagger_ui_dir = File.expand_path('../../swagger-ui', File.dirname(__FILE__))
      @asset_file_server = Rack::File.new(swagger_ui_dir)
    end

    def handles?(env)
      @url_regex === env["PATH_INFO"]
    end

    def call(env)
      puts env["PATH_INFO"]
      env["PATH_INFO"] = env["PATH_INFO"].gsub(@url_regex, '')
      env["PATH_INFO"] = 'index.html' if env["PATH_INFO"] == ''
      @asset_file_server.call(env)
    end
  end
end
