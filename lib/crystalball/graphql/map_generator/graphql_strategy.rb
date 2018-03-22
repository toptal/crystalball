# frozen_string_literal: true

require 'crystalball/map_generator/base_strategy'

module Crystalball
  module GraphQL
    module MapGenerator
      # Map generator strategy to build map of GraphQL type definitions
      # that might affect an example.
      # Patches `GraphQL::ObjectType.define` to get the path of files that call it.
      class GraphQLStrategy
        include ::Crystalball::MapGenerator::BaseStrategy
        include ::Crystalball::MapGenerator::Helpers::PathFilter

        class << self
          attr_accessor :current_schema, :type_definition_paths, :patch_applied

          # Adds the type definition paths of each of the `other_keys`
          # to the type definition paths of `key`
          def augment_type_definition_paths(key, other_keys)
            type_definition_paths[key.object_id] |= other_keys
                                                    .map { |t| type_definition_paths[t.object_id] }
                                                    .flatten
                                                    .compact
          end

          # Checks whether `::GraphQL::Schema` is defined and, if it is, applies
          # the patch to it. It needs to be this way because `graphql` gem is weird.
          def apply_patch
            return unless defined?(::GraphQL::Schema)

            ::GraphQL::Schema.class_eval do
              prepend Patch
            end

            self.patch_applied = true
          end

          # Same as `apply_patch` but raises error if `::GraphQL::Schema` is not defined
          # @see Crystalball::GraphQL::MapGenerator::GraphQLStrategy.apply_patch
          def apply_patch!
            apply_patch || raise(
              NameError,
              "::GraphQL::Schema is not defined. You need to `require 'graphql'` in order to use this strategy"
            )
          end

          def type_definition_paths_during
            apply_patch! unless patch_applied
            self.current_schema = nil

            yield

            return [] unless current_schema
            type_definition_paths[current_schema.object_id]
          end
        end

        attr_accessor :root

        # Tracer to run on every GraphQL query.
        # Simply sets the executed flag on each execution
        class Tracer
          def self.trace(_, data)
            schema = data[:multiplex]&.schema
            return yield unless schema

            GraphQLStrategy.current_schema = schema
            GraphQLStrategy.augment_type_definition_paths(schema, schema.types.values)

            yield
          end
        end

        # Adds the `GraphQLStrategy::Tracer` to all `GraphQL::Schema`s
        module Patch
          def initialize
            super
            @tracers = [Tracer]
          end
        end

        def initialize(root: Dir.pwd)
          self.class.type_definition_paths = {}
          @root_path = root
        end

        def after_register
          self.class.apply_patch
          tracer.enable
        end

        def before_finalize
          tracer.disable
        end

        # Adds to the map the files in which `GraphQL::ObjectType.define` is called.
        # Filters paths to only those inside root path.
        # Raises error if `::GraphQL` is not defined.
        # @param [Crystalball::CaseMap] case_map - object holding example metadata and affected files
        def call(case_map, _)
          paths = self.class.type_definition_paths_during do
            yield case_map
          end

          case_map.push(*paths)
        end

        private

        def tracer
          @tracer ||= TracePoint.new(:call) do |tp|
            next unless tp.method_id == :ensure_defined
            this = tp.binding.eval('self')

            paths = filter(caller_locations.map(&:path).reject { |p| p =~ %r{/spec} })

            self.class.type_definition_paths[this.object_id] ||= []
            self.class.type_definition_paths[this.object_id]  |= paths
          end
        end
      end
    end
  end
end
