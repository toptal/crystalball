require 'crystalball/map_storage/yaml_storage'
require 'crystalball/source_diff/file_diff'
require 'crystalball/source_diff'
require 'crystalball/predictor'
require 'crystalball/execution_detector'
require 'crystalball/case_map'
require 'crystalball/map_generator/simple_map'
require 'crystalball/map_generator/persisted_map'
require 'crystalball/map_generator'
require 'crystalball/version'

module Crystalball
  def self.foresee(workdir = '.', map_path = 'execution_map.yml')
    Predictor.new(
      MapStorage::YAMLStorage.new(map_path).load,
      SourceDiff.new(workdir)
    ).cases
  end
end
