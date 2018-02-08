# frozen_string_literal: true

require 'crystalball/source_diff/file_diff'

module Crystalball
  # Wrapper class representing Git source diff for given repo
  class SourceDiff
    include Enumerable
    extend Forwardable

    delegate %i[stats size lines from to] => :git_diff

    # @param [Git::Diff] raw diff made by ruby-git gem
    def initialize(git_diff)
      @git_diff = git_diff
    end

    # Iterates over each changed file of diff
    #
    # @param [Proc] block to yield for each change
    def each
      changeset.each { |file| yield file }
    end

    def empty?
      changeset.none?
    end

    # @return [Git::Repository] object which stores info about origin repo of diff
    def repository
      git_diff.instance_variable_get(:@base)
    end

    private

    attr_reader :git_diff

    # TODO: Include untracked to changeset
    def changeset
      @changeset ||= git_diff.map { |file_diff| FileDiff.new(file_diff) }
    end
  end
end
