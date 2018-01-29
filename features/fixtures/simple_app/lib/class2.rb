# frozen_string_literal: true

require_relative 'module1'

# Simple class 2
class Class2
  include Module1

  attr_reader :var

  def initialize(var = 2)
    @var = var
  end

  def bar
    'bar of Class2'
  end
end
