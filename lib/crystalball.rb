# frozen_string_literal: true

require 'crystalball/git_repo'
require 'crystalball/extensions/git'
require 'crystalball/rspec/prediction_builder'
require 'crystalball/rspec/runner'
require 'crystalball/prediction'
require 'crystalball/predictor'
require 'crystalball/predictor/modified_execution_paths'
require 'crystalball/predictor/modified_specs'
require 'crystalball/predictor/modified_support_specs'
require 'crystalball/predictor/associated_specs'
require 'crystalball/case_map'
require 'crystalball/execution_map'
require 'crystalball/map_generator'
require 'crystalball/map_generator/configuration'
require 'crystalball/map_generator/coverage_strategy'
require 'crystalball/map_generator/allocated_objects_strategy'
require 'crystalball/map_generator/described_class_strategy'
require 'crystalball/map_storage/yaml_storage'
require 'crystalball/version'

# Main module for the library
module Crystalball
  # Prints the list of specs which might fail
  #
  # @param [String] workdir - path to the root directory of repository (usually contains .git folder inside). Default: current directory
  # @param [String] map_path - path to the execution map. Default: execution_map.yml
  # @param [Proc] block - used to configure predictors
  #
  # @example
  #   Crystalball.foresee do |predictor|
  #     predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new
  #     predictor.use Crystalball::Predictor::ModifiedSpecs.new
  #   end
  def self.foresee(workdir: '.', map_path: 'execution_map.yml', &block)
    map = MapStorage::YAMLStorage.load(Pathname(map_path))
    Predictor.new(map, GitRepo.open(Pathname(workdir)), from: map.commit, &block).prediction.compact
  end
end
