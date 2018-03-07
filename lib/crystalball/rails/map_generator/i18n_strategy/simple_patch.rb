# frozen_string_literal: true

require 'i18n'

module Crystalball
  module Rails
    class MapGenerator
      class I18nStrategy
        # Module to add new patched `load_file`, `store_translations` and `lookup`
        # methods to `I18n::Backend::Simple`.
        module SimplePatch
          class << self
            # Patches `I18n::Backend::Simple`.
            def apply!
              ::I18n::Backend::Simple.class_eval do
                include SimplePatch

                %i[load_file store_translations lookup].each do |method|
                  alias_method :"cb_original_#{method}", method
                  alias_method method, :"cb_patched_#{method}"
                end
              end
            end

            # Reverts original behavior of `I18n::Backend::Simple`
            def revert!
              ::I18n::Backend::Simple.class_eval do
                %i[load_file store_translations lookup].each do |method|
                  alias_method method, :"cb_original_#{method}"
                  undef_method :"cb_patched_#{method}"
                end
              end
              ::I18n.reload!
            end
          end

          # Will replace original `I18n::Backend::Simple#load_file`.
          # Stores filename in current thread
          def cb_patched_load_file(filename, *args)
            Thread.current[:cb_locale_file_name] = filename
            cb_original_load_file(filename, *args)
          end

          # Will replace original `I18n::Backend::Simple#store_translations`.
          # Adds filename for each value
          def cb_patched_store_translations(locale, data, *args)
            cb_add_filename_to_values(data, Thread.current[:cb_locale_file_name])
            cb_original_store_translations(locale, data, *args)
          end

          # Will replace original `I18n::Backend::Simple#lookup`.
          # Records origin filename of each value used.
          def cb_patched_lookup(*args)
            value = cb_original_lookup(*args)
            cb_remove_and_track_filename_from_values(value)
          end

          private

          def cb_add_filename_to_values(data, filename)
            data.each do |key, value|
              case value
              when Hash
                cb_add_filename_to_values(value, filename)
              else
                data[key] = {cb_filename: filename, cb_value: value}
              end
            end
          end

          def cb_remove_and_track_filename_from_values(data)
            return data unless data.is_a?(Hash)

            if data.key?(:cb_filename)
              ::Crystalball::Rails::MapGenerator::I18nStrategy.locale_files << data[:cb_filename]
              return data[:cb_value]
            end

            data.each.with_object({}) do |(key, value), collector|
              collector[key] = cb_remove_and_track_filename_from_values(value)
            end
          end
        end
      end
    end
  end
end
