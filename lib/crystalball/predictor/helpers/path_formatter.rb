# frozen_string_literal: true

module Crystalball
  class Predictor
    module Helpers
      # Helper module for converting relative path to RSpec format
      module PathFormatter
        def format_paths(paths)
          paths.map { |path| format_path(path) }
        end

        def format_path(path)
          path.start_with?('./') ? path : "./#{path}"
        end
      end
    end
  end
end
