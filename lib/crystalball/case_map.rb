# frozen_string_literal: true

module Crystalball
  # Data object to store execution map for specific example
  class CaseMap
    attr_reader :uid, :file_path, :affected_files
    extend Forwardable

    delegate %i[push] => :affected_files

    # @param [String] example - id of example
    # @param [Array<String>] affected_files - list of files affected by example
    def initialize(example, affected_files = [])
      @uid = example.id
      @file_path = example.file_path
      @affected_files = affected_files
    end
  end
end
