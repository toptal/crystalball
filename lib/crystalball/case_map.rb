# frozen_string_literal: true

module Crystalball
  # Data object to store execution map for specific example
  class CaseMap
    attr_reader :uid, :affected_files
    extend Forwardable

    delegate %i[push] => :affected_files

    # @param [String] id of example
    # @param [Array<String>] list of files affected by example
    def initialize(example, affected_files = [])
      @uid = build_uid(example)
      @affected_files = affected_files
    end

    private

    def build_uid(example)
      example.id
    end
  end
end
