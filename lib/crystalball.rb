# frozen_string_literal: true

require 'crystalball/map_storage/yaml_storage'
require 'crystalball/git_repo'
require 'crystalball/predictor'
# TODO: remove redundant requires
require 'crystalball/execution_detector'
require 'crystalball/case_map'
require 'crystalball/map_generator/simple_map'
require 'crystalball/map_generator/standard_map'
require 'crystalball/map_generator'
require 'crystalball/version'

# Main module for the library
module Crystalball
  def self.foresee(workdir: '.', map_path: 'execution_map.yml')
    predictor = Predictor.new(
      MapStorage::YAMLStorage.new(Pathname(map_path)).load,
      GitRepo.new(workdir).source_diff
    )

    yield predictor

    predictor.cases
  end
end
