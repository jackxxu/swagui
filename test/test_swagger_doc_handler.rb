require 'test_helper'

class TestSwaggerDocHandler < Minitest::Test

  include Rack::Test::Methods

  def app
    @app ||= Swagui::App.new(Rack::Lobster.new, url: '/doc', path: 'test/doc')
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

  def test_template_attributes_removed_from_api_docs
    get '/doc/api-docs'
    assert last_response.ok?
    response_json = JSON.parse(last_response.body)
    assert_nil response_json['template']
  end

  def test_template_attributes
    get '/doc/api-docs'
    get '/doc/account'
    assert last_response.ok?
    response_json = JSON.parse(last_response.body)
    assert_equal response_json['produces'], ['application/json']
    assert_equal response_json['consumes'], ['application/json']
    assert_equal response_json['apis'].first['operations'].first['responseMessages'].map {|x| x['code']}, [200, 400]
  end


end
