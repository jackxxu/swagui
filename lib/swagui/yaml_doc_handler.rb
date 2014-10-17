require 'yaml'

module Swagui
  class YAMLDocHandler

    def initialize(app)
      @app = app
      @api_json_template = nil # used to store the template settings that applies to all apis
    end

    def call(env)
      @app.call(env).tap do |response|

        response[1].merge!("Content-Type"=>"application/json") # response is always json content

        if yaml_response?(response) # yml response needs to be re=processed.
          body = []
          response[2].each do |f|
            body << YAML::load(f).tap do |response_hash|
              if response[2].path.end_with?('api-docs.yml')
                process_api_docs_api_listing(response_hash, response[2].path )
              else
                process_schemas(response_hash)
                process_base_path(response_hash, response[2].path, env)
              end
            end.to_json
          end

          response[2] = body

          response[1].merge!("Content-Length"=> body.first.size.to_s)
        end
      end
    end

    private

      def yaml_response?(response)
        response[2].respond_to?(:path) && response[2].path.end_with?('.yml')
      end

      def process_schemas(response_hash)

        deep_merge!(response_hash, @api_json_template) if @api_json_template

        (response_hash['apis'] || []).each do |api_hash|
          (api_hash['operations'] || []).each do |operations_hash|
            operation_name = operations_hash['nickname']

            merge_schema!(operations_hash, response_hash, operation_name)

            (operations_hash['parameters'] || []).each do |parameters_hash|
              merge_schema!(parameters_hash, response_hash, "#{operation_name}-#{parameters_hash['name']}")
            end

            (operations_hash['responseMessages'] || []).each do |response_messages_hash|
              merge_schema!(response_messages_hash, response_hash, "#{operation_name}-Response-#{response_messages_hash['code']}", true)
            end
          end
        end
      end

      def merge_schema!(parent_hash, response_hash, name, response_model = false)
        if schema_file = parent_hash.delete('schema')
          schema_file_path = Swagui.file_full_path(schema_file)
          schema = JsonSchemaParser.parse(schema_file_path, name)
          schema.models.each {|m| (response_hash['models'] ||= {})[m['id']] = m }
          parent_hash.merge!(schema_hash(schema, response_model))
        end
      end

      def schema_hash(schema, response_model = false)
        if response_model
          {'responseModel' => schema.name}
        elsif schema.array?
          {'type' => 'array', 'items' => { '$ref' => schema.name} }
        else
          {'type' => schema.name}
        end
      end

      def process_api_docs_api_listing(response_hash, doc_path)
        if response_hash['models'].nil? # requesting the root

          @api_json_template = response_hash.delete('template')

          dir_path = File.dirname(doc_path)
          files = Dir["#{File.dirname(doc_path)}/*.yml"].map {|x| x.gsub(dir_path, '').gsub('.yml', '')}
          files.each do |file|
            unless file == '/api-docs'
              (response_hash['apis'] ||= []) << {'path' => "/..#{file}"}
            end
          end
        end
      end

      def process_base_path(response_hash, doc_path, env)
        if response_hash['basePath'].nil?
          request = Rack::Request.new(env)
          response_hash['basePath'] = (request.base_url + request.script_name)
        end
      end

      def deep_merge!(actual, template)
        merger = proc { |key, v1, v2|
          if (Hash === v1 && Hash === v2)
            v1.merge!(v2, &merger)
          elsif (Array === v2 && Array === v1)
            v1 = v1 + v2
          elsif (Hash === v2 && Array === v1)
            v1.map {|x| x.merge!(v2, &merger)}
          else
            v1
          end
        }
        actual.merge!(template, &merger)
      end
  end
end
