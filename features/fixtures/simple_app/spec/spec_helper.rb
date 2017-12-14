# frozen_string_literal: true

require 'rspec'
require_relative '../../../../lib/crystalball'
Crystalball::MapGenerator.start!

require_relative '../lib/class1.rb'
require_relative '../lib/class2.rb'
