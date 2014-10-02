module Swagui
  class SwaggerDocHandler
    def initialize(path, url)
      @url_regex = Regexp.new("^#{url}")
      app_doc_dir = Swagui.file_full_path(path || url)

      raise "swagger api doc directory #{app_doc_dir} does not exist" unless File.directory?(app_doc_dir)

      @app_file_server = YAMLDocHandler.new(Rack::File.new(app_doc_dir))
    end

    def handles?(env)
      @url_regex === env["PATH_INFO"]
    end

    def call(env)
      path = env["PATH_INFO"].gsub(@url_regex, '') # root path renders index.html

      first_valid_file_response = ['', '.json', '.yml'].map do |ext|
        @app_file_server.call(env.merge('PATH_INFO' => "#{path}#{ext}", 'REQUEST_METHOD' => 'GET'))
      end.find {|res| res[0] == 200 }

      first_valid_file_response || [404, {"Content-Type"=>"application/json"}, '']
    end

  end
end
