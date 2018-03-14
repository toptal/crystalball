# Crystalball

Crystalball is a Ruby library which implements [Regression Test Selection mechanism](https://tenderlovemaking.com/2015/02/13/predicting-test-failues.html) originally published by Aaron Patterson. Its main purpose is to select a subset of your test suite which should be run to ensure your changes didn't break anything.

[![Build Status](https://travis-ci.org/toptal/crystalball.svg?branch=master)](https://travis-ci.org/toptal/crystalball)
[![Maintainability](https://api.codeclimate.com/v1/badges/c8bfc25a43a1a2ecf964/maintainability)](https://codeclimate.com/github/toptal/crystalball/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/c8bfc25a43a1a2ecf964/test_coverage)](https://codeclimate.com/github/toptal/crystalball/test_coverage)

## Installation

Add this line to your application's Gemfile:

```ruby
group :test do
  gem 'crystalball'
end
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install crystalball

## Usage

1. Start MapGenerator in your `spec_helper` before you loaded any file of your app. E.g.
  ```ruby
  Crystalball::MapGenerator.start! do |config|
    config.register Crystalball::MapGenerator::CoverageStrategy.new
  end
  ```
1. Run your test suite on clean branch with green build. This step will create file `execution_map.yml` in your project root
1. Make some changes to your app code
1. To see list of tests which might fail because of your changes, call:
```ruby
Crystalball.foresee do |predictor|
  predictor.use Crystalball::Predictor::ModifiedExecutionPaths.new
  predictor.use Crystalball::Predictor::ModifiedSpecs.new
end
```

## Map Generator

There are different map generator strategies that can (and should) be used together for better predictions. Each one has its own benefits and drawbacks, so they should be configured to best fit your needs.

### CoverageStrategy

Uses coverage information to detect which files are covered by the given spec (i.e. the files that, if changed, may potentially break the spec);
To customize the way the execution detection works, pass an object that responds to #detect and returns the paths to the strategy initialization:

```ruby
# ...
config.register Crystalball::MapGenerator::CoverageStrategy.new(MyDetector)
```

By default, the execution detector is a `Crystalball::MapGenerator::CoverageStrategy::ExecutionDetector`, which filters out the paths outside the root and converts absolute paths to relative.

### AllocatedObjectsStrategy

Looks for the files in which the objects created during the spec execution are defined. It is considerably slower than `CoverageStrategy`.
To use this strategy, use the convenient method `.build` which takes two optional keyword arguments: `only`, used to define the classes or modules to have their descendants tracked (defaults to `[]`); and `root`, which is the path where the detection will take place (defaults to `Dir.pwd`).
Here's an example that tracks allocation of `ActiveRecord::Base` objects:

```ruby
# ...
config.register Crystalball::MapGenerator::AllocatedObjectsStrategy.build(only: ['ActiveRecord::Base'])
```

That method is fine for most uses, but if you need to further customize the behavior of the strategy, you can directly instantiate the class.

```ruby
# ...
config.register Crystalball::MapGenerator::AllocatedObjectsStrategy
  .new(execution_detector: MyCustomDetector, object_tracker: MyCustomTracker)
```

The initialization takes two keyword arguments: `execution_detector` and `object_tracker`.
`execution_detector` must be an object that responds to `#detect` receiving a list of objects and returning the paths affected by said objects. `object_tracker` is something that responds to `#created_during` which yields to the caller and returns the array of objects allocated during the execution of the block.

### DescribedClassStrategy

This strategy will take each example that has a `described_class` (i.e. examples inside `describe` blocks of classes and not strings) and add the paths where the described class and its ancestors are defined to the case map of the example;

To use it, add to your `Crystalball::MapGenerator.start!` block:

```ruby
# ...
config.register Crystalball::MapGenerator::DescribedClassStrategy.new
```

As with `AllocatedObjectsStrategy`, you can pass a custom execution detector (an object that responds to `#detect` and returns the paths) to the initialization:

```ruby
# ...
config.register Crystalball::MapGenerator::DescribedClassStrategy.new(MyDetector)
```

### ActionViewStrategy

This is a Rails specific strategy that patches `ActionView::Template#compile!` to map the examples to affected views. Use it as follows:

```ruby
require 'crystalball/rails'
# ...
config.register Crystalball::MapGenerator::ActionViewStrategy.new
```

### Custom strategies

You can create your own strategy and use it with the map generator. Any object that responds to `#call(case_map, example)` (where `case_map` is a `Crystalball::CaseMap` and `example` a `RSpec::Core::Example`) and augmenting its list of affected files using `case_map.push(*paths_to_files)`.
Check out the [implementation](https://github.com/toptal/crystalball/tree/master/lib/crystalball/map_generator) of the default strategies for details.

Keep in mind that all the strategies configured for the map generator will run for each example of your test suite, so it may slow down the generation process considerably.

## Predictor

The predictor can also be customized with different strategies:

### AssociatedSpecs

Needs to be configured with rules for detecting which specs should be on the prediction.
`predictor.use Crystalball::Predictor::AssociatedSpecs.new(from: %r{models/(.*).rb}, to: "./spec/models/%s_spec.rb")`
will add `./spec/models/foo_spec.rb` to prediction when `models/foo.rb` changes.
This strategy does not depend on a previoulsy generated case map.

### ModifiedExecutionPaths

Checks the case map and the diff to see which specs are affected by the new or modified files.

### ModifiedSpecs

As the name implies, checks for modified specs. The scope can be modified by passing a regex as argument, which defaults to `%r{spec/.*_spec\.rb\z}`.
This strategy does not depend on a previoulsy generated case map.

### Custom strategies

As with the map generator you may define custom strategies for prediction. It must be an object that responds to `#call(diff, case_map)` (where `diff` is a `Crystalball::SourceDiff` and `case_map` is a `Crystalball::CaseMap`) and returns an array of paths.

Check out the [implementation](https://github.com/toptal/crystalball/tree/master/lib/crystalball/predictor) of the default strategies for details.
## Under the hood

TODO: Write good description for anyone who wants to customize behavior

## Plans

1. Different strategies for source diff
1. Different strategies for failure predictor
1. Different strategies for execution map
1. Guard replacement
1. integration for git hook

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/toptal/crystalball. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

