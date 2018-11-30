# frozen_string_literal: true

require_relative '../spec/rails_helper'

SimpleCov.add_filter 'features/support/'

Dir[Pathname(__dir__).join('support', '**', '*.rb')].each { |f| require f }
