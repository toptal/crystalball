# frozen_string_literal: true

require 'rspec'

require_relative '../../../../lib/crystalball'
require_relative '../../../../lib/crystalball/rails'
Crystalball::MapGenerator.start! do |c|
  c.register Crystalball::MapGenerator::CoverageStrategy.new
  c.register Crystalball::MapGenerator::AllocatedObjectsStrategy.build(only: ['Object'])
  c.register Crystalball::MapGenerator::DescribedClassStrategy.new
  c.register Crystalball::Rails::MapGenerator::ActionViewStrategy.new
  c.register Crystalball::Rails::MapGenerator::I18nStrategy.new
end

require_relative '../standard_predictor'
require_relative 'support/shared_examples/module1.rb'
require_relative 'support/shared_contexts/action_view.rb'
require_relative '../lib/locales.rb'
require_relative '../lib/module1.rb'
require_relative '../lib/class1.rb'
require_relative '../lib/class1_reopen.rb'
require_relative '../lib/class2.rb'
require_relative '../lib/class2_eval.rb'
require_relative '../models/model1.rb'
