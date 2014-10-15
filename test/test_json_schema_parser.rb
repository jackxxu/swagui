require 'test_helper'

class TestJsonSchemaParser < Minitest::Test

  def test_parse_file
    file_path = File.expand_path('test/doc/schemas/account_post_request_body.schema.json', Dir.pwd)
    result = Swagui::JsonSchemaParser.parse(file_path, 'PostAccount')
    assert_equal result.class, Swagui::JsonSchema
    assert_equal result.name, 'PostAccount'
    assert_equal result.models.size, 4
    assert_equal result.models.first.class, Hash
  end

end
