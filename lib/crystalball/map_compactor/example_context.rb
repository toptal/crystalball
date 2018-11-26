# frozen_string_literal: true

module Crystalball
  module MapCompactor
    # Class representing RSpec context data
    class ExampleContext
      attr_reader :address

      def initialize(address)
        @address = address
      end

      def parent
        @parent ||= begin
          parent_uid = address.split(':')[0..-2].join(':')
          parent_uid.empty? ? nil : self.class.new(parent_uid)
        end
      end

      def include?(example_id)
        example_id =~ /\[#{address}[\:\]]/
      end

      def depth
        @depth ||= address.split(':').size
      end
    end
  end
end
