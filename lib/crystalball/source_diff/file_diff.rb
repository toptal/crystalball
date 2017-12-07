# frozen_string_literal: true

module Crystalball
  class SourceDiff
    # Data object for single file in Git repo diff
    class FileDiff
      def initialize(git_repo, git_diff)
        @git_repo = git_repo
        @git_diff = git_diff
      end

      def modified?
        git_diff.type == 'modified'
      end

      def deleted?
        git_diff.type == 'deleted'
      end

      def new?
        git_diff.type == 'new'
      end

      def relative_path
        git_diff.path
      end

      def full_path
        File.join(git_repo.dir.path, git_diff.path)
      end

      def method_missing(method, *args, &block)
        git_diff.public_send(method, *args, &block) || super
      end

      def respond_to_missing?(method, include_private = false)
        git_diff.respond_to?(method, false) || super
      end

      private

      attr_reader :git_diff, :git_repo
    end
  end
end
