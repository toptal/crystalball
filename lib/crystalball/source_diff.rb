# frozen_string_literal: true

require 'crystalball/source_diff/file_diff'

module Crystalball
  # Class representing Git source diff for given repo
  class SourceDiff
    include Enumerable
    extend Forwardable

    delegate %i[stats size lines] => :git_diff

    def initialize(git_diff)
      @git_diff = git_diff
    end

    def each
      changeset.each { |file| yield file }
    end

    def empty?
      changeset.none?
    end

    def repository
      git_diff.instance_variable_get(:@base)
    end

    def from
      git_diff.instance_variable_get(:@from)
    end

    def to
      git_diff.instance_variable_get(:@to)
    end

    private

    attr_reader :git_diff

    # TODO: Include untracked to changeset
    def changeset
      @changeset ||= git_diff.map { |file_diff| FileDiff.new(file_diff) }
    end
  end
end
