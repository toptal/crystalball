# Crystalball

Crystalball is a Ruby library which implements [Regression Test Selection mechanism](https://tenderlovemaking.com/2015/02/13/predicting-test-failues.html) originally published by Aaron Patterson. 
Its main purpose is to select a minimal subset of your test suite which should be run to ensure your changes didn't break anything.

## Installation

Please check our [installation instructions](https://github.com/toptal/crystalball#installation).

## Basic Usage

1. Start MapGenerator in your `spec_helper` before you loaded any file of your app. E.g.

        if ENV['CRYSTALBALL'] == 'true' do
          Crystalball::MapGenerator.start! do |config|
            config.register Crystalball::MapGenerator::CoverageStrategy.new
          end
        end

1. Run your test suite with Crystaball enabled on clean master branch with green build. `CRYSTALBALL=true bundle exec rspec .` This step will generate file `tmp/crystalball_data.yml` in your project root. This file contains useful profiling data for Crystalball.
1. Make some changes to your app code
1. Run `bundle exec crystalball` to build a prediction and run RSpec with it. Check out [RSpec runner section](runner.md) for customization details.

Keep in mind that as your target branch (usually master) code changes your execution maps will become outdated, 
so you need to regenerate execution maps regularly.

## Advanced Usage

Crystalball workflow can be divided into 2 parts. 
1. Full build profiling where Crystalball gathers some data about your RSpec suite for later use in predictions. This is where map generators do their job.
2. Actual predicting where Crystalball uses profiling info from step above and tries to get best prediction possible. This is where predictors do their job.

Both of these steps can be heavily customized and enchanted based on your project specifics and your needs.

You might want to check:

* [map generators docs](map_generators.md) for details related to suite profiling.
* [predictors docs](predictors.md) for details related to actual prediction.
* [runner docs](runner.md) for runner configuration details. 


## Spring integration

It's very easy to integrate Crystalball with [Spring](https://github.com/rails/spring). Check out [spring-commands-crystalball](https://github.com/pluff/spring-commands-crystalball) for details.
