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
    assert_equal response_json['models'].keys.first, 'PostAccount-body'
    refute response_json['basePath'].nil?
    assert_equal response_json['apis'].first['operations'].first['parameters'].first['type'], 'PostAccount-body'

    # body schema parsing
    assert_equal response_json['apis'].first['operations'].last['type'], 'array'
    assert_equal response_json['apis'].first['operations'].last['items'], {'$ref' => 'GETAccounts'}
  end

end
