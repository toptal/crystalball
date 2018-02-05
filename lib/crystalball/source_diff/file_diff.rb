# frozen_string_literal: true

module Crystalball
  class SourceDiff
    # Data object for single file in Git repo diff
    class FileDiff
      # @param [Git::DiffFile] raw diff for a single file made by ruby-git gem
      def initialize(git_diff)
        @git_diff = git_diff
      end

      def moved?
        git_diff.patch =~ /rename from.*\nrename to/
      end

      def modified?
        !moved? && git_diff.type == 'modified'
      end

      def deleted?
        git_diff.type == 'deleted'
      end

      def new?
        git_diff.type == 'new'
      end

      # @return relative path to file
      def relative_path
        git_diff.path
      end

      # @return new relative path to file if file was moved
      def new_relative_path
        return relative_path unless moved?

        git_diff.patch.match(/rename from.*\nrename to (.*)/)[1]
      end

      def method_missing(method, *args, &block)
        git_diff.public_send(method, *args, &block) || super
      end

      def respond_to_missing?(method, *)
        git_diff.respond_to?(method, false) || super
      end

      private

      attr_reader :git_diff
    end
  end
end
