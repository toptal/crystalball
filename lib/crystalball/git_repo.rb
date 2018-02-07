# frozen_string_literal: true

require 'git'
require 'crystalball/source_diff'

module Crystalball
  # Wrapper class representing Git repository
  class GitRepo
    attr_reader :repo_path

    class << self
      # @return [Crystalball::GitRepo] instance for given path
      def open(repo_path)
        new(repo_path) if exists?(repo_path)
      end

      # Check if given path is under git control (contains .git folder)
      def exists?(repo_path)
        Dir.exist?("#{repo_path}/.git")
      end
    end

    # @param path to repository root folder
    def initialize(repo_path)
      @repo_path = repo_path
    end

    # Check if repository has no uncommitted changes
    def pristine?
      diff.empty?
    end

    # Proxy all unknown calls to `Git` object
    def method_missing(method, *args, &block)
      repo.public_send(method, *args, &block) || super
    end

    def respond_to_missing?(method, *)
      repo.respond_to?(method, false) || super
    end

    # Creates diff
    #
    # @param [String] to which commit to build a diff. Default: HEAD
    # @param [String] from which commit to build a diff. Default: nil, will build diff of uncommitted changes
    # @return [SourceDiff]
    def diff(from = 'HEAD', to = nil)
      SourceDiff.new(repo.diff(from, to), self)
    end

    private

    def repo
      @repo ||= Git.open(repo_path)
    end
  end
end
