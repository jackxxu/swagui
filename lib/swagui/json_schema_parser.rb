module Swagui
  class JsonSchemaParser

    # returns a hash of interlinked models
    # the first one is the root
    def self.parse(file, prefix = "")
      schema_json = JSON.load(File.open(file).read)
      JsonSchema.new(schema_json, prefix)
    end
  end
end
