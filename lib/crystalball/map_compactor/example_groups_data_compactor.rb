# frozen_string_literal: true

require 'crystalball/map_compactor/example_context'

module Crystalball
  module MapCompactor
    # Class representing example groups data compacting logic for a single file
    class ExampleGroupsDataCompactor
      # @param [Hash] plain_data a hash of examples and used files
      def self.compact!(plain_data)
        new(plain_data).compact!
      end

      def compact!
        contexts = extract_contexts(plain_data.keys).sort_by(&:depth)

        contexts.each do |context|
          compact_data[context.address] = compact_context!(context)
        end
        compact_data
      end

      private

      attr_reader :compact_data, :plain_data

      def initialize(plain_data)
        @plain_data = plain_data
        @compact_data = {}
      end

      def compact_context!(context) # rubocop:disable Metrics/MethodLength
        result = nil
        plain_data.each do |example_uid, used_files|
          next unless context.include?(example_uid)

          if result.nil?
            result = used_files
            result -= deep_used_files(context.parent) if context.parent
          else
            result &= used_files
          end
        end
        result
      end

      def deep_used_files(context)
        result = compact_data[context.address]
        result += deep_used_files(context.parent) if context.parent
        result
      end

      def extract_contexts(example_uids)
        result = []
        example_uids.each do |example_uid|
          context_numbers = /\[(.*)\]/.match(example_uid)[1].split(':')
          until context_numbers.empty?
            result << ExampleContext.new(context_numbers.join(':'))
            context_numbers.pop
          end
        end
        result.compact.uniq(&:address)
      end
    end
  end
end
