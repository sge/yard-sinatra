if defined?(ESO::CrudMounter)
  require "yard"
  require 'pry'

  module YARD
    module CrudMounter
      class << self
        attr_accessor :mounted_resources
      end
      @mounted_resources = []

      class MountedResource
        attr_reader :code_object
        delegate :klass, :parent_code_object, :crud_actions, :serializer, :resource, to: :code_object

        def initialize(code_object)
          @code_object = code_object
        end

        def singular
          klass.name.underscore.downcase
        end

        def plural
          klass.name.underscore.pluralize
        end

        def foreign_key
          if parent
            "#{singular}_id".to_sym
          else
            :id
          end
        end

        def group_path
          if parent
            parent.group_path + "/#{plural}"
          else
            '/:id'
          end
        end

        def instance_path
          if parent
            parent.group_path + "/:#{foreign_key}"
          else
            '/:id'
          end
        end

        def path(type)
          if type == :group
            group_path.chomp(':id')
          else
            instance_path
          end
        end

        Route = Struct.new(:http_method, :path)

        def routes
          @routes ||= {
            index:  Route.new('GET', path(:group)),
            show:   Route.new('GET', path(:instance)),
            create: Route.new('POST', path(:group)),
            update: Route.new('PUT', path(:instance)),
            delete: Route.new('DELETE', path(:instance))
          }
        end

        def curl_path(action)
          # the ID is always 1!
          resource_path(action).sub(/:[^\/]+/, '1')
        end

        def resource_path(action)
          resource.downcase + routes[action.to_sym].path
        end

        def sample_response
          {data:{}, meta:{}}.to_json
        end

        Param = Struct.new(:name, :type, :text)

        def params_for(action)
          case action.to_sym
          when :index
            []
          when :show
            [Param.new('id', :integer, "#{resource} ID to look up")]
          when :create
            assignable_params
          when :update
            assignable_params
          when :delete
            [Param.new('id', :integer, "#{resource} ID to destroy")]
          end
        end

        def assignable_params
          attributes = 
            if !klass.accessible_attributes.to_a.empty?
              klass.accessible_attributes.to_a
            else
              klass.attribute_names - klass.protected_attributes.to_a
            end
          (attributes - ['created_at', 'updated_at']).compact.inject([]) do |a, attribute|
            binding.pry unless klass.columns_hash[attribute]
            a << Param.new("#{singular}[#{attribute}]", klass.columns_hash[attribute].type, '')
          end
        end

        def description_for(action)
          case action.to_sym
          when :index
            "Retrieve all #{plural}"
          when :show
            "Retrieve a specific #{singular}"
          when :create
            "Create a new #{singular}"
          when :update
            "Update a #{singular}"
          when :delete
            "Delete a #{singular}"
          end
        end

        def parent
          self.class.new(parent_code_object)
        rescue NoMethodError
          nil
        end

        def height
          return 0 unless parent
          parent.height + 1
        end
      end
    end

    module Handlers
      module CrudMounter
        class MountHandler < YARD::Handlers::Ruby::Base
          handles method_call(:mount)

          def process
            name = statement.parameters.first.jump(:tstring_content, :ident).source
            object = YARD::CodeObjects::MethodObject.new(namespace, name)
            object.klass = name.constantize
            object.resource = namespace.tag(:api_resource_name).text
            object.parent_code_object = owner unless owner.is_a?(RootObject)
            register(object)
            parse_block(statement.last.last, :owner => object)

            YARD::CrudMounter.mounted_resources << YARD::CrudMounter::MountedResource.new(object)
          end
        end

        class ActionsHandler < YARD::Handlers::Ruby::Base
          handles method_call(:actions)

          def process
            return unless owner.is_a?(MethodObject)
            return unless owner.klass

            owner.crud_actions = call_params
          end
        end

        class SerializerHandler < YARD::Handlers::Ruby::Base
          handles method_call(:serializer)

          def process
            return unless owner.is_a?(MethodObject)
            return unless owner.klass

            owner.serializer = call_params.constantize rescue ESO::CrudMounter::DefaultSerializer
          end
        end
      end
    end
  end
end