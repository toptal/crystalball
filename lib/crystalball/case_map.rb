module Crystalball
  class CaseMap
    attr_reader :case_uid, :coverage

    def initialize(example, coverage)
      @case_uid = uid(example)
      @coverage = coverage
    end

    private

    def uid(example)
      example.location_rerun_argument
    end
  end
end
