# frozen_string_literal: true

require_relative 'module2'

Class2.class_eval do
  extend Module2
  include Module1
end
