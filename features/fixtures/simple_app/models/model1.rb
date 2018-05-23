# frozen_string_literal: true

# Simple model 1
class Model1 < ActiveRecord::Base
  self.table_name = 'model1s'

  def initialize(field)
    self.field = field
  end

  has_and_belongs_to_many :model2s

  attr_accessor :field
end
