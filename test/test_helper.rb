require 'bundler/setup'
require 'minitest/autorun'
Bundler.require(:default, :test)

require 'swagui'
require 'rack/lobster'
require 'json'
class Minitest::Test
  def mounted_app
    Rack::Builder.new do
      use Swagui::App, url: '/doc', path: 'test/doc'
      run Rack::Lobster.new
    end
  end
end
