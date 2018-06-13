# frozen_string_literal: true

# An important class
class ImportantClass
  def self.foo
    Object.const_get('Class2').new # so as to not be caught by parser strategy
  end

  def self.bar
    Object.const_get('Class1').new # so as to not be caught by parser strategy
  end
end
