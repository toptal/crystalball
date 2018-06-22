# frozen_string_literal: true

require 'rspec'
require 'active_record'
require 'sqlite3'
require 'factory_bot'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

require_relative '../../../../lib/crystalball'
require_relative '../../../../lib/crystalball/rails'
require_relative '../../../../lib/crystalball/factory_bot'
require_relative '../../../../lib/crystalball/map_generator/parser_strategy'

# MAP_GENERATOR_CONFIG

require_relative 'support/shared_examples/module1.rb'
require_relative 'support/shared_contexts/action_view.rb'
require_relative '../db/schema.rb'
require_relative '../lib/locales.rb'
require_relative '../lib/module1.rb'
require_relative '../lib/class1.rb'
require_relative '../lib/class1_reopen.rb'
require_relative '../lib/class2.rb'
require_relative '../lib/class2_eval.rb'
require_relative '../lib/important_class.rb'
require_relative '../models/model1.rb'
require_relative '../models/model2.rb'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
