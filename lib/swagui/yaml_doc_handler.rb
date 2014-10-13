require 'yaml'

module Swagui
  class YAMLDocHandler

    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env).tap do |response|

        response[1].merge!("Content-Type"=>"application/json") # response is always json content

        if yaml_response?(response) # yml response needs to be re=processed.
          body = []
          response[2].each do |f|
            body << YAML::load(f).tap do |response_hash|
              process_schemas(response_hash)
              process_api_docs_api_listing(response_hash, response[2].path )
              process_base_path(response_hash, response[2].path, env)
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
        (response_hash['apis'] || []).each do |api_hash|
          (api_hash['operations'] || []).each do |operations_hash|
            (operations_hash['parameters'] || []).each do |parameters_hash|
              if schema_file = parameters_hash.delete('schema')
                schema_file_path = Swagui.file_full_path(schema_file)
                schema = JsonSchemaParser.parse(schema_file_path, "#{operations_hash['nickname']}-Request")
                schema.models.each {|m| (response_hash['models'] ||= {})[m['id']] = m }
                parameters_hash.merge!('type' => schema.name)
              end
            end
            (operations_hash['responseMessages'] || []).each do |response_messages_hash|
              if schema_file = response_messages_hash.delete('schema')
                schema_file_path = Swagui.file_full_path(schema_file)
                schema = JsonSchemaParser.parse(schema_file_path, "#{operations_hash['nickname']}-Response-#{response_messages_hash['message'].gsub(' ', '-')}")
                schema.models.each {|m| (response_hash['models'] ||= {})[m['id']] = m }
                response_messages_hash.merge!('responseModel' => schema.name)
              end
            end
          end
        end
      end

      def process_api_docs_api_listing(response_hash, doc_path)
        if doc_path.end_with?('api-docs.yml') && response_hash['models'].nil? # requesting the root
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
        if !doc_path.end_with?('api-docs.yml') && response_hash['basePath'].nil?
          request = Rack::Request.new(env)
          response_hash['basePath'] = (request.base_url + request.script_name)
        end
      end

  end
end
