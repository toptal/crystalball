# frozen_string_literal: true

module Crystalball
  # Data object for execution map for given example
  class CaseMap
    attr_reader :uid, :file_path, :affected_files
    extend Forwardable

    delegate %i[push] => :affected_files

    def initialize(example, affected_files = [])
      @uid = example.id
      @file_path = example.file_path
      @affected_files = affected_files
    end
  end
end
