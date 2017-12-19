# frozen_string_literal: true

require 'git'
require 'crystalball/source_diff'

module Crystalball
  # Wrapper class representing Git repository
  class GitRepo
    attr_reader :repo_path

    def initialize(repo_path)
      @repo_path = repo_path
    end

    def pristine?
      diff.empty?
    end

    def method_missing(method, *args, &block)
      repo.public_send(method, *args, &block) || super
    end

    def respond_to_missing?(method, *)
      repo.respond_to?(method, false) || super
    end

    def diff(*args)
      SourceDiff.new(repo.diff(*args))
    end

    private

    def repo
      @repo ||= Git.open(repo_path)
    end
  end
end
