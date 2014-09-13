module Swagui
  class SwaggerDocHandler
    def initialize(path, url)
      @url_regex = Regexp.new("^#{url}")
      app_doc_dir = File.expand_path(path || url, Dir.pwd)
      @app_file_server = Rack::File.new(app_doc_dir)
    end

    def handles?(env)
      @url_regex === env["PATH_INFO"]
    end

    def call(env)
      path = env["PATH_INFO"].gsub(@url_regex, '') # root path renders index.html

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
  end
end
