# frozen_string_literal: true

require_relative '../spec/spec_helper'

SimpleCov.add_filter 'features/support/shared_contexts/'

Dir[Pathname(__dir__).join('support', '**', '*.rb')].each { |f| require f }
