module Crystalball
  class ExecutionDetector
    attr_reader :root_path

    def initialize(root_path)
      @root_path = root_path
    end

    def detect(before, after)
      result = []
      after.each do |file_name, after_coverage|
        next unless file_name =~  /^#{root_path}.*/
        next if before[file_name] == after_coverage

        result << file_name.sub("#{root_path}/", '')
      end
      result
    end
  end
end
