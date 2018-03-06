# frozen_string_literal: true

module Crystalball
  # Storage for execution map
  class ExecutionMap
    extend Forwardable

    # Simple data object for map metadata information
    class Metadata
      attr_accessor :commit, :type, :version

      # @param [String] SHA of commit
      # @param [String] type of execution map
      def initialize(commit: nil, type: nil, version:)
        @commit = commit
        @type = type
        @version = version
      end

      def to_h
        {type: type, version: version, commit: commit}
      end
    end

    # Current version of generated map
    # Change minor part in case of backward compatible changes of map
    # Change major part in case of backward incompatible changes of map
    VERSION = 1.0

    attr_reader :cases, :metadata

    delegate %i[commit commit=] => :metadata
    delegate %i[size] => :cases

    # @param [Hash] add or override metadata of execution map
    # @param [Hash] initial list of cases
    def initialize(metadata: {}, cases: {})
      @cases = cases

      version = metadata[:version].to_f

      if cases.any?
        version = 1.0 if version.zero?
        guard_version_compatibility(version)
      elsif version.nonzero?
        guard_version_compatibility(version)
      else
        version = VERSION
      end

      @metadata = Metadata.new(type: self.class.name, version: version, **metadata)
    end

    # Adds case map to the list
    #
    # @param [Crystalball::CaseMap]
    def <<(case_map)
      cases[case_map.uid] = case_map.affected_files.uniq
    end

    # Remove all cases
    def clear!
      self.cases = {}
    end

    private

    def guard_version_compatibility(version)
      version = 1.0 if version.zero?
      raise "Execution map incompatible version: #{version}. Expected: ~#{VERSION}" if version.floor != VERSION.floor
    end

    attr_writer :cases, :metadata
  end
end
