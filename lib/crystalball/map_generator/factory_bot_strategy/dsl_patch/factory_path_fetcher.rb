# frozen_string_literal: true

module Crystalball
  class MapGenerator
    class FactoryBotStrategy
      module DSLPatch
        # This module is used to fetch file path with factory definition from callstack
        module FactoryPathFetcher
          # Fetches file path with factory definition from callstack
          #
          # @return [String]
          def self.fetch
            factories_definition_paths = FactoryBotStrategy
                                         .factory_bot_constant
                                         .definition_file_paths
                                         .map { |path| Pathname(path).expand_path.to_s }

            factory_definition_call = caller.find do |method_call|
              factories_definition_paths.any? do |path|
                method_call.start_with?(path)
              end
            end

            factory_definition_call.split(':').first
          end
        end
      end
    end
  end
end
