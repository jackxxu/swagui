module Swagui
  class JsonSchema

    attr_reader :name

    def initialize(schema_hash, name)
      @name = name
      @schema_hash = schema_hash
      @nested_objects = []

      @schema_hash['properties'].each do |pname, pattributes|
        if pattributes['type'] == 'object'
          nested_object_name = "#{@name}-#{pname}"
          @schema_hash['properties'][pname] = {'$ref' => nested_object_name }
          @nested_objects << JsonSchema.new(pattributes, nested_object_name)
        end
      end
    end

    def properties
      @schema_hash['properties']
    end

    def models
      all_objects.map do |schema|
        {
          'id' => schema.name,
          'properties' => schema.properties
        }
      end
    end

    def all_objects
      ([self] + @nested_objects.map {|x| x.all_objects}).flatten
    end

  end
end
