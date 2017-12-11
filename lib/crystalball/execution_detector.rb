# frozen_string_literal: true

module Crystalball
  # Class for detecting code execution path based on coverage information diff
  class ExecutionDetector
    attr_reader :root_path

    def initialize(root_path)
      @root_path = root_path
    end

    def detect(before, after)
      after.select { |file_name, after_coverage| file_name.start_with?(root_path) && before[file_name] != after_coverage }
           .map { |file_name, _| file_name.sub("#{root_path}/", '') }
    end
  end
end
