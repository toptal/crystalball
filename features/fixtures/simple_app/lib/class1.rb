# frozen_string_literal: true

require_relative 'module1'

# Simple class 1
class Class1
  include Module1

  attr_reader :var

  def initialize(var = 1)
    @var = var
  end

  def bar
    'bar of Class1'
  end
end
