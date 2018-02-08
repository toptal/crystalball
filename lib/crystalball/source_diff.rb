# frozen_string_literal: true

require 'crystalball/source_diff/file_diff'

module Crystalball
  # Wrapper class representing Git source diff for given repo
  class SourceDiff
    include Enumerable
    extend Forwardable

    delegate %i[stats size lines] => :git_diff

    # @param [Git::Diff] raw diff made by ruby-git gem
    def initialize(git_diff, repository = nil)
      @git_diff = git_diff
      @repository = repository
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
      @repository ||= GitRepo.open(git_diff.instance_variable_get(:@base).dir.path)
    end

    # @return [String] SHA of commit diff build from
    def from
      git_diff.instance_variable_get(:@from)
    end

    # @return [String] SHA of commit diff build to
    def to
      git_diff.instance_variable_get(:@to)
    end

    # Checks if path exists for a diff
    #
    # @param [String] path to check
    def path_exist?(path)
      command = `git --git-dir=#{repository.repo.path} --work-tree=#{repository.dir.path} cat-file -e #{to}:#{path} 2>&1`
      command.empty?
    end

    private

    attr_reader :git_diff

    # TODO: Include untracked to changeset
    def changeset
      @changeset ||= git_diff.map { |file_diff| FileDiff.new(file_diff) }
    end
  end
end
