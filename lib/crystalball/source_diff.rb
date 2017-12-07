# frozen_string_literal: true

require 'crystalball/source_diff/file_diff'
require 'git'

module Crystalball
  # Class representing Git source diff for given repo
  class SourceDiff
    include Enumerable

    attr_reader :repo_path

    def initialize(repo_path)
      @repo_path = repo_path
    end

    def each
      changeset.each { |file| yield file }
    end

    private

    def changeset
      unless defined? @changeset
        @changeset = repo.diff.map do |file_diff|
          FileDiff.new(repo, file_diff)
        end
      end
      @changeset
    end

    def repo
      @repo ||= Git.open(repo_path)
    end
  end
end
