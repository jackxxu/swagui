module Swagui
  class JsonSchema

    attr_reader :type
    attr_reader :name

    def initialize(schema_hash, name)
      @nested_objects = []

      @name = name
      @schema_hash = schema_hash

      if @schema_hash['type'] == 'array'
        @type = 'array'
        nested_object_name = name
        @nested_objects << JsonSchema.new(@schema_hash['items'], nested_object_name)
        @schema_hash['items'] = {'$ref' => nested_object_name }
      else
        @type = 'class'
        (@schema_hash['properties'] ||= []).each do |pname, pattributes|
          if pattributes['type'] == 'object' || (pattributes['type'] == 'array' && !pattributes['items'].nil?)
            nested_object_name = "#{@name}-#{pname}"
            if pattributes['type'] == 'object'
              @schema_hash['properties'][pname] = {'$ref' => nested_object_name }
            else
              @schema_hash['properties'][pname] = { 'type' => 'array', 'items' => {'$ref' => nested_object_name } }
            end
            @nested_objects << JsonSchema.new(pattributes, nested_object_name)
          end
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
      ([self].select {|x| !x.properties.nil?} + @nested_objects.map {|x| x.all_objects}).flatten
    end

    def array?
      type == 'array'
    end

  end
end
