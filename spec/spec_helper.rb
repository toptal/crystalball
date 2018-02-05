# frozen_string_literal: true

require "bundler/setup"
require 'simplecov'
SimpleCov.start
SimpleCov.add_filter 'bundle/'
SimpleCov.add_filter 'spec/support/shared_contexts/'

Dir[Pathname(__dir__).join('support', '**', '*.rb')].each { |f| require f }

require "action_view"
require "crystalball"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
