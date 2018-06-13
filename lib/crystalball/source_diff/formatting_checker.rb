# frozen_string_literal: true

module Crystalball
  class SourceDiff
    # Determinates if file_diff's patch contains changes for whitespaces or comments only
    module FormattingChecker
      class << self
        # Returns `true` if file_diff's patch contains changes for whitespaces or comments only
        #
        # @param [Crystalball::SourceDiff::FileDiff] file_diff
        # @return [Boolean]
        def pure_formatting?(file_diff)
          return false unless stripable_file?(file_diff.path) && file_diff.modified?

          patch = file_diff.patch.to_s.lines

          return true if patch.empty?

          added = collect_patch(patch, '+')
          removed = collect_patch(patch, '-')

          trim_patch(added) == trim_patch(removed)
        end

        private

        STRIPABLE_FILES = %w[.rb .erb].freeze # TODO: move to config

        def stripable_file?(file_name)
          STRIPABLE_FILES.include?(Pathname(file_name).extname)
        end

        def collect_patch(patch, sign)
          patch.each.with_object([]) do |line, result|
            next if line.start_with?('+++', '---', '@@') # Skip meta of a patch
            result << line[1..-1] if line.start_with?(sign, ' ')
          end
        end

        def trim_patch(patch)
          patch.map do |line|
            line = line.gsub(/\s/, '')
            line.start_with?('#') || line.empty? ? nil : line
          end.compact
        end
      end
    end
  end
end
