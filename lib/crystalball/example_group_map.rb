# frozen_string_literal: true

module Crystalball
  # Data object to store execution map for specific example
  class ExampleGroupMap
    attr_reader :uid, :file_path, :used_files
    extend Forwardable

    delegate %i[push each] => :used_files

    # @param [Example|ExampleGroup] example - RSpec example or example group
    # @param [Array<String>] used_files - list of files affected by example
    def initialize(example, used_files = [])
      @uid = example.id
      @file_path = example.file_path
      @used_files = used_files
    end
  end
end
