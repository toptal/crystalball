# frozen_string_literal: true

require_relative 'module1'

Class2.class_eval do
  include Module1
end
