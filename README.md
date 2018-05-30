# Crystalball

Crystalball is a Ruby library which implements [Regression Test Selection mechanism](https://tenderlovemaking.com/2015/02/13/predicting-test-failues.html) originally published by Aaron Patterson.
Its main purpose is to select a minimal subset of your test suite which should be run to ensure your changes didn't break anything.

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

Please see our [official documentation](docs/index.md).

### Versioning

We use [semantic versioning](https://semver.org/) for our [releases](https://github.com/toptal/crystalball/releases).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/toptal/crystalball.
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

Crystalball is released under the [MIT License](https://opensource.org/licenses/MIT).


