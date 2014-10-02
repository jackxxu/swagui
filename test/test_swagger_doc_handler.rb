require 'test_helper'

class TestSwaggerDocHandler < Minitest::Test

  include Rack::Test::Methods

  def app
    Rack::Lint.new(mounted_app)
  end

  def test_loading_api_docs_root
    get '/doc/api-docs'
    assert last_response.ok?
    response_json = JSON.parse(last_response.body)
    assert_equal response_json['apis'].size, 1
    assert_equal response_json['apis'].first['path'], '/../account'
  end

  def test_loading_individual_api_doc
    get '/doc/account'
    assert last_response.ok?
    response_json = JSON.parse(last_response.body)
    assert_equal response_json['apis'].size, 1
    assert response_json['models'].size > 1
    assert_equal response_json['models'].keys.first, 'PostAccount-Request'
    refute response_json['basePath'].nil?
  end
end
