require 'json'
require 'watir'
require 'watir-webdriver'
require 'rack'
require 'webrick'

module Swagui
  class Cors
    def initialize(app)
      @app = app
    end
    def call(env)
      @app.call(env).tap {|r| r[1].merge!("Access-Control-Allow-Origin" => "*")}
    end
  end
end

namespace :swagui do

  desc "compare the local yaml settings with current deployment settings"
  task "generate" do |t, args|

    swagger_doc_loc  = ARGV[1]
    swagger_doc_path = "#{Rake.application.original_dir}/#{swagger_doc_loc}/.."
    swagui_path      = File.expand_path('../../../swagger-ui', __FILE__)

    begin
      JSON.parse(File.read(swagger_doc_loc))
    rescue JSON::ParserError
      fail "Error: unable to parse JSON from #{swagger_doc_loc}"
    end

    doc_server = WEBrick::HTTPServer.new(:Port => 9300, AccessLog: []).tap do |server|
      server.mount '/',
        Rack::Handler::WEBrick,
        Swagui::Cors.new(
          Rack::Directory.new(swagger_doc_path)
        )
    end

    ui_server = WEBrick::HTTPServer.new(:Port => 9301, AccessLog: []).tap do |server|
      server.mount '/',
        Rack::Handler::WEBrick,
        Rack::Directory.new(swagui_path)
    end

    Thread.new { doc_server.start }
    Thread.new { ui_server.start }
    trap('INT') do
      doc_server.shutdown
      ui_server.shutdown
      exit
    end

    browser = Watir::Browser.new
    browser.goto 'http://localhost:9301/index.html?baseurl=http://localhost:9300/swagger.json'

    File.open("test-#{Time.now.to_i}.html", 'w') do |f|
      f.write browser.html.gsub("%21", "!")
    end

    browser.close
  end

end
