require 'active_support/all'

def init

  # copy over assets from swagger-ui
  emit_swagger_ui_assets

  # write out the actual swagger definition
  options.serializer.serialize 'js/api.js', JSON.pretty_generate(swagger_api_definition)

  # overwrite the swagger index.html distributable with a custom one
  Templates::Engine.with_serializer('index.html', options.serializer) do
    erb :swagger
  end

end

def swagger_friendly_path(path)
  path.split('/').map { |part| part.starts_with?(':') ? "{#{part.gsub(':','')}}" : part }.join('/')
end

def path_parameters(path)
  path.split('/').select { |part| part.starts_with?(':') }.map { |var| var.gsub(':','') }
end

def swagger_api_definition
  base_path = ENV['SWAGGER_BASE_PATH'].present? ? ENV['SWAGGER_BASE_PATH'] : 'http://127.0.0.1:9292/'

  swagger_definition = {
        apiVersion: '1.0',
    swaggerVersion: '1.1',
          basePath: base_path,
      resourcePath: File.basename(File.expand_path('.')),
              apis: [],
            models: {}
  }

  # scan the routes for "resources" which (by convention) are the first 
  # part of the path, ala: /resources/:id

  resources = {}
  YARD::Sinatra.routes.each do |route|
    resource                             = route.http_path.split('/')[1]
    resources[resource]                  = {} unless resources[resource].present?
    resources[resource][route.http_path] = [] unless resources[resource][route.http_path].present?
    resources[resource][route.http_path] << route
  end

  # build the models section by inspecting the actual ActiveRecord models themselves
  # this is slightly error-prone in that our "resource" names may not match one-to-one
  # with models

  resources.keys.each do |resource|
    klass = "SleepyGiant::Model::Subscriptions::#{resource.singularize.classify}".constantize rescue next
    swagger_definition[:models][resource.singularize.classify] = {
              id: resource.singularize.classify,
      properties: klass.columns.inject({}) { |m,i| m[i.name] = { type: i.type }; m }
    }
  end

  # for each resource and path combination, assemble the API definitions
  # for now this is lacking any kind of parameters (assumedly to come from 
  # the @param tags once I figure it out)

  resources.keys.each do |resource|
    resources[resource].keys.each do |path|
      api = { path: swagger_friendly_path(path), operations: [], description: "Operations about #{resource}" }
      resources[resource][path].each do |route|
        parameters = []
        path_parameters(route.http_path).each do |param|
          parameters << {
                   name: param,
            description: "Path-parameter #{param}",
              paramType: 'path',
               required: true,
               dataType: 'string'
          }
        end
        api[:operations] << {
              httpMethod: route.http_verb,
                 summary: route.docstring,
                   notes: route.docstring,
                nickname: "#{route.http_verb.titleize}#{route.http_path.gsub(':','').camelize.gsub('::','')}",
           responseClass: resource.singularize.classify,
              parameters: parameters,
          errorResponses: []
        }
      end
      swagger_definition[:apis] << api
    end
  end

  swagger_definition
end

def javascripts
  %w(js/swagger-ui.js)
end

def stylesheets
  %w()
end

def emit_swagger_ui_assets
  Dir[File.join(File.dirname(__FILE__),'swagger-ui','dist','**','*')].each do |file| 
    relative_path     = file.gsub(File.dirname(__FILE__),'')[1..-1]
    emitted_file_path = file.gsub(File.join(File.dirname(__FILE__),'swagger-ui','dist'),'')[1..-1]
    asset emitted_file_path, file(relative_path, false) unless File.directory?(file)
  end
end

def asset(path, content)
  if options.serializer
    log.capture("Generating asset #{path}") do
      options.serializer.serialize(path, content)
    end
  end
end