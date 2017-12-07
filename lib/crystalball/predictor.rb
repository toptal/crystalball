# frozen_string_literal: true

module Crystalball
  # Class that predicts test failures with given execution map and sources diff
  class Predictor
    attr_reader :map, :diff

    def initialize(map, source_diff)
      @map = map
      @diff = source_diff
    end

    def cases
      map.map do |case_uid, case_map|
        case_uid if diff.any? { |file| case_map.include?(file.relative_path) }
      end.compact
    end
  end
end
