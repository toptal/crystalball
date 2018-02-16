# frozen_string_literal: true

# Simple module 1
module Module1
  attr_accessor :field

  def foo(arg)
    "foo of Module1 #{arg}".strip
  end
end
