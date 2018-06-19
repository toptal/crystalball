# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Logger' do
  let(:output_stream) { StringIO.new }
  let(:log_file_output_stream) { StringIO.new }
  let(:log_file) { 'tmp/crystalball.log' }
  let!(:stdout_logger) { ::Logger.new(output_stream) }
  let!(:file_logger) { ::Logger.new(log_file_output_stream) }
  let(:configured_level) { 'warn' }

  before do
    ENV['CRYSTALBALL_LOG_LEVEL'] = configured_level
    ENV['CRYSTALBALL_LOG_FILE'] = log_file

    allow(::Logger).to receive(:new).with(STDOUT).and_return(stdout_logger)
    allow(::Logger).to receive(:new).with(log_file).and_return(file_logger)
  end

  after do
    ENV.delete('CRYSTALBALL_LOG_LEVEL')
    ENV.delete('CRYSTALBALL_LOG_FILE')
    Crystalball.reset_logger
  end

  it 'logs everything to file' do
    log_everything
    result = log_file_output_stream.string.delete("\n")
    expect(result).to match(/.*DEBUG.*INFO.*WARN.*ERROR.*FATAL.*UNKNOWN/)
  end

  it 'logs every level equal or above to specified log level' do
    log_everything
    result = output_stream.string.delete("\n")
    expect(result).not_to match(/.*DEBUG.*INFO.*/)
    expect(result).to match(/WARN.*ERROR.*FATAL.*UNKNOWN/)
  end

  private

  def log_everything
    # A log of each type
    Crystalball.log(:debug, 'DEBUG')
    Crystalball.log(:info, 'INFO')
    Crystalball.log(:warn, 'WARN')
    Crystalball.log(:error, 'ERROR')
    Crystalball.log(:fatal, 'FATAL')
    Crystalball.log(:unknown, 'UNKNOWN')
  end
end
