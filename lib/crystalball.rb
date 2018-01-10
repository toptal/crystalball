# frozen_string_literal: true

require 'crystalball/git_repo'
require 'crystalball/predictor'
require 'crystalball/execution_detector'
require 'crystalball/case_map'
require 'crystalball/execution_map'
require 'crystalball/map_generator'
require 'crystalball/map_generator/configuration'
require 'crystalball/map_storage/yaml_storage'
require 'crystalball/version'

# Main module for the library
module Crystalball
  def self.foresee(workdir: '.', map_path: 'execution_map.yml')
    map = MapStorage::YAMLStorage.new(Pathname(map_path)).load
    predictor = Predictor.new(map, GitRepo.open(workdir).diff(map.commit))

    yield predictor

    predictor.cases
  end
end
