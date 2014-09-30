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

      response = first_valid_file_response(path) || [404, {"Content-Type"=>"application/json"}, '']

      if response[2].path.end_with?('.yml') # yml response needs to be re=processed.
        body = ''
        response[2].each {|f| body = YAML::load(f).to_json}
        response[2] = [body]
        response[1].merge!("Content-Length"=> body.size.to_s)
      end

      response[1].merge!("Content-Type"=>"application/json") # response is always json content

      response
    end

    private

      def first_valid_file_response(path)
        ['', '.json', '.yml'].map do |ext|
          @app_file_server.call('PATH_INFO' => "#{path}#{ext}", 'REQUEST_METHOD' => 'GET')
        end.find {|res| res[0] == 200 }
      end
  end
end
