# frozen_string_literal: true

# Simple model 1
class Model1
  class << self
    attr_accessor :table_name
  end

  self.table_name = 'model1'
end
