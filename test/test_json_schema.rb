require 'test_helper'

class TestJsonSchema < Minitest::Test

  def setup
    sampole_schema_file = File.expand_path('doc/schemas/account_post_request_body.schema.json', File.dirname(__FILE__))
    @schema_json = JSON.load(File.open(sampole_schema_file).read)
  end

  def test_objects_method_returns_array
    schema = Swagui::JsonSchema.new(@schema_json, 'PostAccount')
    assert_equal schema.all_objects.size, 2
  end

  def test_models_methods_return_array_of_hash
    schema = Swagui::JsonSchema.new(@schema_json, 'PostAccount')
    assert_equal schema.models.size, 2
    assert_equal schema.models.map {|x| x['id']}, ['PostAccount', 'PostAccount-contact']
  end

end
