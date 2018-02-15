# frozen_string_literal: true

require_relative 'module1'

# Simple class 2
class Class2
  include Module1

  def bar
    'bar of Class2'
  end
end
