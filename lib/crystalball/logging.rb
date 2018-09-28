# frozen_string_literal: true

require 'logger'

module Crystalball
  # This module logs information to the standard output based on the configured log level,
  # and also logs unfiltered information to the configured log file.
  module Logging
    def log(severity_sym, *args, &block)
      output_stream.log(severity(severity_sym), *args, &block)
      log_file_output_stream.log(severity(severity_sym), *args, &block)
    end

    def self.extended(base)
      base.private_class_method :severity, :output_stream, :log_file_output_stream, :configured_level, :config
    end

    # @api private
    def reset_logger
      @output_stream = nil
      @log_file_output_stream = nil
    end

    def severity(severity_sym)
      ::Logger.const_get(severity_sym.to_s.upcase)
    end

    def output_stream
      @output_stream ||= ::Logger.new(STDOUT).tap do |logger|
        logger.level = severity(configured_level)
      end
    end

    def log_file_output_stream
      @log_file_output_stream ||= begin
        config['log_file'].dirname.mkpath
        ::Logger.new(config['log_file']).tap do |logger|
        logger.level = ::Logger::DEBUG
        end
      end
    end

    def configured_level
      config['log_level'].to_sym
    end

    def config
      @config ||= Crystalball::RSpec::Runner.config
    end
  end
end
