# frozen_string_literal: true

require 'crystalball/source_diff/file_diff'

module Crystalball
  # Class representing Git source diff for given repo
  class SourceDiff
    include Enumerable

    attr_reader :repo

    def initialize(repo)
      @repo = repo
    end

    def each
      changeset.each { |file| yield file }
    end

    private

    # TODO: Include untracked to changeset
    def changeset
      unless defined? @changeset
        @changeset = repo.diff.map do |file_diff|
          FileDiff.new(repo, file_diff)
        end
      end
      @changeset
    end
  end
end
