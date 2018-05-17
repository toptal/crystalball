# frozen_string_literal: true

# Simple model 2
class Model2 < ActiveRecord::Base
  has_and_belongs_to_many :model1s
end
