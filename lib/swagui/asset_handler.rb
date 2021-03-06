module Swagui
  class AssetHandler

    def initialize(path)
      @url_regex = Regexp.union(Regexp.new("^\/swagger-ui"), Regexp.new("^#{path}\/?$"))
      swagger_ui_dir = File.expand_path('../../swagger-ui', File.dirname(__FILE__))

      raise "swagger ui assets directory #{swagger_ui_dir} does not exist"  unless File.directory?(swagger_ui_dir)

      @asset_file_server = Rack::File.new(swagger_ui_dir)
    end

    def handles?(env)
      @url_regex === env["PATH_INFO"]
    end

    def call(env)
      env["PATH_INFO"] = env["PATH_INFO"].gsub(@url_regex, '')
      env["PATH_INFO"] = 'index.html' if env["PATH_INFO"] == ''
      @asset_file_server.call(env)
    end
  end
end
