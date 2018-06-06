# frozen_string_literal: true

module Git
  # Represents git repo object itself.
  class Base
    # `git merge-base ...`. Returns common ancestor for all passed commits
    #
    # @param [Array<Object>] args - list of commits to process. Last argument can be options for merge-base command
    # @return [Git::Object::Commit]
    def merge_base(*args)
      gcommit(lib.merge_base(*args))
    end
  end
end
