# frozen_string_literal: true

module Crystalball
  # Class for Crystalball prediction results
  class Prediction
    def initialize(cases)
      @cases = cases
    end

    def compact
      result = []
      sort_by(&:length).each do |c|
        result << c unless result.any? { |r| c.start_with?(r, "./#{r}") }
      end
      result
    end

    def to_a
      cases
    end

    def method_missing(*args, &block)
      cases.respond_to?(*args) ? cases.public_send(*args, &block) : super
    end

    def respond_to_missing?(*args)
      cases.respond_to?(*args)
    end

    private

    attr_reader :cases
  end
end
