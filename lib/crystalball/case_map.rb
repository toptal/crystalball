# frozen_string_literal: true

module Crystalball
  # Data object for execution map for given example
  class CaseMap
    attr_reader :uid, :coverage

    def initialize(example, coverage)
      @uid = build_uid(example)
      @coverage = coverage
    end

    private

    def build_uid(example)
      example.id
    end
  end
end
