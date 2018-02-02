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

