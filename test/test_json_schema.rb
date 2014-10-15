require 'test_helper'

class TestJsonSchema < Minitest::Test

  def setup
    sample_schema_file = File.expand_path('doc/schemas/account_post_request_body.schema.json', File.dirname(__FILE__))
    @schema_json = JSON.load(File.open(sample_schema_file).read)

    sample_array_schema_file = File.expand_path('doc/schemas/account_get_request_body.schema.json', File.dirname(__FILE__))
    @array_schema_json = JSON.load(File.open(sample_array_schema_file).read)
  end

  def test_objects_method_returns_array
    schema = Swagui::JsonSchema.new(@schema_json, 'PostAccount')
    assert_equal schema.all_objects.size, 4
  end

  def test_models_methods_return_array_of_hash
    schema = Swagui::JsonSchema.new(@schema_json, 'PostAccount')
    assert_equal schema.models.size, 4
    assert_equal schema.models.map {|x| x['id']}, ["PostAccount", "PostAccount-contact", "PostAccount-contact-phones", "PostAccount-entries"]
    assert_equal schema.models.first['properties']['entries'], {'type' => 'array', 'items' => {"$ref"=>"PostAccount-entries"}}
  end

  def test_array_schema
    schema = Swagui::JsonSchema.new(@array_schema_json, 'GetAccount')
    assert_equal schema.models.size, 3
    assert_equal schema.models.map {|m| m['id']}, %w(GetAccount GetAccount-tags GetAccount-dimensions)
  end

end
