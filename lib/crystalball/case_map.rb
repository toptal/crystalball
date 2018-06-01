# frozen_string_literal: true

module Crystalball
  # Data object to store execution map for specific example
  class CaseMap
    attr_reader :uid, :file_path, :affected_files

    # @param [String] example - id of example
    # @param [Array<String>] affected_files - list of files affected by example
    def initialize(example, affected_files = {})
      @uid = example.id
      @file_path = example.file_path
      @affected_files = affected_files
    end

    def push(*files, strategy:)
      (affected_files[strategy] ||= []).push(*files)
    end

    def each(&block)
      affected_files.values.flatten.uniq.each(&block)
    end
  end
end
