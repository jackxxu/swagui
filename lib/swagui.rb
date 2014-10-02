require 'swagui/version'
require 'swagui/app'
require 'swagui/asset_handler'
require 'swagui/swagger_doc_handler'
require 'swagui/yaml_doc_handler'
require 'swagui/json_schema_parser'
require 'swagui/json_schema'


module Swagui

  def self.file_full_path(relative_path)
    File.expand_path(relative_path, Dir.pwd)
  end

end
