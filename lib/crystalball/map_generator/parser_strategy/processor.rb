# frozen_string_literal: true

require 'parser/current'

module Crystalball
  class MapGenerator
    class ParserStrategy
      # Parses the given source files and adds the class and module definitions
      # to the `consts_defined` array.
      class Processor
        def consts_defined_in(path)
          self.current_scope = nil
          self.consts_defined = []
          parse_and_process(path)
          consts_defined
        end

        def consts_interacted_with_in(path)
          self.current_scope = nil
          self.consts_interacted_with = []
          parse_and_process(path)
          consts_interacted_with
        end

        protected

        attr_accessor :consts_defined, :consts_interacted_with, :current_scope

        private

        def on_send(node)
          const = filtered_children(node).detect { |c| c.type == :const }
          return unless const

          add_constant_interacted(qualified_name_from_node(const), nil)
        end

        def on_casgn(node)
          namespace, name, = node.children
          scope_name = namespace ? qualified_name(qualified_name_from_node(namespace), current_scope) : current_scope
          add_constant_defined(name, scope_name)
        end

        def on_class(node)
          const, superclass, body = node.children
          add_constant_interacted(qualified_name_from_node(superclass), current_scope) if superclass
          process_class_or_module(const, body)
        end

        def on_module(node)
          const, body = node.children
          process_class_or_module(const, body)
        end

        def process_class_or_module(const, body)
          const_name = qualified_name_from_node(const)
          result = add_constant_defined(const_name, current_scope)
          self.current_scope = result if body && nested_consts?(body)
        end

        def nested_consts?(node)
          filtered_children(node).any? { |c| %i[const casgn].include?(c.type) || nested_consts?(c) }
        end

        def filtered_children(node)
          return [] unless node.is_a?(Parser::AST::Node)

          node.children.grep(Parser::AST::Node)
        end

        def parse_and_process(path)
          node = Parser::CurrentRuby.parse(File.read(path))
          process_node_and_children(node)
        rescue Parser::SyntaxError
          nil
        end

        # @param  [AST::Node, nil] node
        # @return [String, nil]
        def process(node)
          return if node.nil?

          on_handler = :"on_#{node.type}"
          __send__(on_handler, node) if respond_to?(on_handler, true)
        end

        def process_node_and_children(node)
          process(node)
          filtered_children(node).each do |child|
            process_node_and_children(child)
          end
        end

        def add_constant_defined(name, scope)
          add_constant(name, scope, collection: consts_defined)
        end

        def add_constant_interacted(name, scope)
          add_constant(name, scope, collection: consts_interacted_with)
        end

        def add_constant(name, scope, collection:)
          collection ||= []
          qualified_const_name = qualified_name(name, scope)
          collection << qualified_const_name
          qualified_const_name
        end

        # @param [Parser::AST::Node] node - :const node in format s(:const, scope, :ConstName)
        #   where scope can be `nil` or another :const node.
        #   For example, `Foo::Bar` is represented as `s(:const, s(:const, nil, :Foo), :Bar)`
        def qualified_name_from_node(node)
          return unless node.is_a?(Parser::AST::Node)

          scope, name = node.to_a
          return name.to_s unless scope

          qualified_name(name, qualified_name_from_node(scope))
        end

        def qualified_name(name, scope = nil)
          return "#{scope.sub(/\A::/, '')}::#{name}" if scope

          name.to_s
        end
      end
    end
  end
end
