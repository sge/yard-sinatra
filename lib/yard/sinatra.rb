require "yard"

module YARD
  module Sinatra
    def self.routes
      YARD::Handlers::Sinatra::AbstractRouteHandler.routes
    end

    def self.error_handlers
      YARD::Handlers::Sinatra::AbstractRouteHandler.error_handlers
    end
  end

  module CodeObjects
    class RouteObject < MethodObject
      attr_accessor :http_verb, :http_path, :real_name

      def name(prefix=false)
        super(false)
      end

      def type 
        :method
      end
    end
  end

  module Handlers
    # Displays Sinatra routes in YARD documentation.
    # Can also be used to parse routes from files without executing those files.
    module Sinatra
      # Logic both handlers have in common.
      module AbstractRouteHandler
        def self.routes
          @routes ||= []
        end

        def self.error_handlers
          @error_handlers ||= []
        end

        def register_route(verb, path, doc=nil)
          method_name = "#{verb}\t#{path.gsub(/\s/, "\t")}"
          real_name   = "#{verb} #{path}"
          route = register CodeObjects::RouteObject.new(namespace, method_name, :instance) do |o|
            o.visibility = :public
            o.source     = statement.source
            o.signature  = real_name
            o.explicit   = true
            o.scope      = scope
            o.http_verb  = verb
            o.http_path  = path
            o.real_name  = real_name
            o.add_file(parser.file, statement.line)
          end

          if route.has_tag?(:data)
            # create the options parameter if its missing
            route.tags(:data).each do |data|
              expected_param = data.name
              unless route.tags(:response_field).find {|x| x.name == expected_param }
                new_tag = YARD::Tags::Tag.new(:response_field, "a customizable response", "Hash", expected_param)
                route.docstring.add_tag(new_tag)
              end
            end
          end

          AbstractRouteHandler.routes << route
          route
        end

        def register_error_handler(verb, doc=nil)
          error_handler = register CodeObjects::RouteObject.new(namespace, verb, :instance) do |o|
            o.visibility = :public
            o.source     = statement.source
            o.signature  = verb
            o.explicit   = true
            o.scope      = scope
            o.http_verb  = verb
            o.real_name  = verb
            o.add_file(parser.file, statement.line)
          end

          AbstractRouteHandler.error_handlers << error_handler
          error_handler
        end
      end

      # Route handler for YARD's source parser.
      class RouteHandler < Ruby::Base
        include AbstractRouteHandler

        handles method_call(:get)
        handles method_call(:post)
        handles method_call(:put)
        handles method_call(:patch)
        handles method_call(:delete)
        handles method_call(:head)
        handles method_call(:not_found)
        namespace_only

        def process
          http_verb = statement.method_name(true).to_s.upcase
          http_path = statement.parameters.first.jump(:tstring_content, :ident).source


          object = case http_verb
          when 'NOT_FOUND'
            register_error_handler(http_verb)
          else
            path = http_path
            path = $1 if path =~ /^"(.*)"$/
            register_route(http_verb, path)
          end

          parse_block(statement.last.last, :owner => object)
        end
      end
    end
  end
end
