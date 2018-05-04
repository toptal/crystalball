# frozen_string_literal: true

require_relative 'class1'
require_relative 'module2'

# Simple class 2
class Class2
  def bar
    Class1.foo
    'bar of Class2'
  end

  def translated_value
    I18n.t(:value)
  end
end
