# frozen_string_literal: true

module Crystalball
  module Rails
    module Helpers
      # Interface for schema parsers
      module BaseSchemaParser
        def self.parse(*_)
          raise NotImplementedError
        end

        # @return [Hash] stored info about all method calls which ended in #method_missing
        attr_accessor :hash

        def initialize
          @hash = {}
        end

        private

        # Store info about call in hash. First argument of method call used as a key
        def method_missing(method_name, *args, &block)
          name = args.shift
          add_to_hash(name, options: [method_name] + args)

          new_parser = self.class.new
          add_to_hash(name, content: new_parser.instance_exec(&block)) if block
          add_to_hash(name, content: new_parser.hash)
          new_parser
        end

        def respond_to_missing?(*_)
          true
        end

        def add_to_hash(name, options: nil, content: nil)
          hash[name] ||= {}
          add_optional(name, :options, options)
          add_optional(name, :content, content)
        end

        def add_optional(name, key, value)
          return unless value

          hash[name][key] ||= []
          hash[name][key] << value
        end
      end
    end
  end
end
