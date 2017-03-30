module Crystalball
  class SourceDiff
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
        git_diff.public_send(method, *args, &block)
      end

      private

      attr_reader :git_diff, :git_repo
    end
  end
end
