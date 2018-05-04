# frozen_string_literal: true

# Simple class 1
class Class1
  attr_reader :var

  def self.foo
    # NOOP
  end

  def initialize(var = 1)
    @var = var
  end

  def bar
    'bar of Class1'
  end
end
