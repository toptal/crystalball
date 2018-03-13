# frozen_string_literal: true

# Simple class 2
class Class2
  def bar
    'bar of Class2'
  end

  def translated_value
    I18n.t(:value)
  end
end
