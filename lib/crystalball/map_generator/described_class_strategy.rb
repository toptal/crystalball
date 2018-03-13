# frozen_string_literal: true

require 'crystalball/map_generator/base_strategy'
require 'crystalball/map_generator/object_sources_detector'

module Crystalball
  class MapGenerator
    # Map generator strategy to get paths to files contains definition of described_class and its
    # ancestors.
    class DescribedClassStrategy
      include BaseStrategy
      extend Forwardable

      attr_reader :execution_detector

      delegate %i[after_register before_finalize] => :execution_detector

      def initialize(execution_detector: ObjectSourcesDetector.new(root_path: Dir.pwd))
        @execution_detector = execution_detector
      end

      def call(case_map, example)
        yield case_map

        described_class = example.metadata[:described_class]

        case_map.push(*execution_detector.detect([described_class])) if described_class
      end
    end
  end
end
