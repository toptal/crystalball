# frozen_string_literal: true
# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exist?(d) ? d : UI.warning('Directory #{d} does not exist')}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch 'config/Guardfile' instead of 'Guardfile'

# Note: The cmd option is now required due to the increasing number of ways
#       rspec may be run, below are examples of the most common uses.
#  * bundler: 'bundle exec rspec'
#  * bundler binstubs: 'bin/rspec'
#  * spring: 'bin/rspec' (This will use spring if running and you have
#                          installed the spring binstubs per the docs)
#  * zeus: 'zeus rspec' (requires the server to be started separately)
#  * 'just' rspec: 'rspec'
require 'guard/compat/plugin'

SPEC_DIRS = ENV.fetch('SPEC_DIRS', 'spec features').split

Guard::Compat::UI.info("spec_paths are #{SPEC_DIRS}")

guard_options = {
  cmd: 'bundle exec rspec',
  # cmd: 'spring crystalball',
  # run_all: { cmd: 'CRYSTALBALL=true rspec' },
  all_on_start: true,
  failed_mode: :focus,
  spec_paths: SPEC_DIRS
}

guard :rspec, guard_options do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Capybara features specs
  # watch(rails.view_dirs)     { |m| rspec.spec.call('features/#{m[1]}') }
  # watch(rails.layouts)       { |m| rspec.spec.call('features/#{m[1]}') }

  # Turnip features and steps
  watch('features')
end
