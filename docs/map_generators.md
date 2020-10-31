# Map generators

## Execution Map Generator

There are different map generator strategies that can (and should) be used together for better predictions. Each one has its own benefits and drawbacks, so they should be configured to best fit your needs.

### Custom map file name

You can customize resulting map filename with `map_storage_path` value. E.g.
```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.map_storage_path = "execution_map_#{ENV['TEST_ENV_NUMBER'].to_i}.yml"
end
```

### CoverageStrategy

Uses coverage information to detect which files are covered by the given spec (i.e. the files that, if changed, may potentially break the spec);
To customize the way the execution detection works, pass an object that responds to #detect and returns the paths to the strategy initialization:

```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::MapGenerator::CoverageStrategy.new(my_detector)
end
```

By default, the execution detector is a `Crystalball::MapGenerator::CoverageStrategy::ExecutionDetector`, which filters out the paths outside of the project root and converts absolute paths to relative.

### AllocatedObjectsStrategy

Looks for the files in which the objects allocated during the spec execution are defined. It is considerably slower than `CoverageStrategy`.
To use this strategy, use the convenient method `.build` which takes two optional keyword arguments: `only`, used to define the classes or modules to have their descendants tracked (defaults to `[]`); and `root`, which is the path where the detection will take place (defaults to `Dir.pwd`).
Here's an example that tracks allocation of `ActiveRecord::Base` objects:

```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::MapGenerator::AllocatedObjectsStrategy.build(only: ['ActiveRecord::Base'])
end
```

That method is fine for most uses, but if you need to further customize the behavior of the strategy, you can directly instantiate the class.

```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::MapGenerator::AllocatedObjectsStrategy
    .new(execution_detector: my_detector, object_tracker: my_tracker)
end
```

The initialization takes two keyword arguments: `execution_detector` and `object_tracker`.
`execution_detector` must be an object that responds to `#detect` receiving a list of objects and returning the paths affected by said objects. `object_tracker` is something that responds to `#used_classes_during` which yields to the caller and returns the array of classes of objects allocated during the execution of the block.

### DescribedClassStrategy

This strategy will take each example that has a `described_class` (i.e. examples inside `describe` blocks of classes and not strings) and add the paths where the described class and its ancestors are defined to the example group map of the example;

To use it, add to your `Crystalball::MapGenerator.start!` block:

```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::MapGenerator::DescribedClassStrategy.new
end
```

As with `AllocatedObjectsStrategy`, you can pass a custom execution detector (an object that responds to `#detect` and returns the paths) to the initialization:

```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::MapGenerator::DescribedClassStrategy.new(my_detector)
end
```

### ParserStrategy

The `ParserStrategy`, as the name suggests parses the files in order to detect which files are affected by an example.
It works by first parsing all (`.rb`) files that match the given pattern under the configured root directory (defaults to current directory) to collect the constants definition paths.
Then, when each example is executed, the used files of the current example group map are parsed to check for method calls to those constants. For that reason, `ParserStrategy` **only works when used with other strategies and is placed at the end of the strategies list**.

To use it, add the `parser` gem to your `Gemfile` and:

```ruby
require 'crystalball/map_generator/parser_strategy'
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::MapGenerator::ParserStrategy.new(pattern: /\A(app)|(lib)/)
end
```

### ActionViewStrategy

To use Rails specific strategies you must first `require 'crystalball/rails'`.
This strategy patches `ActionView::Template#compile!` to map the examples to affected views. Use it as follows:

```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::Rails::MapGenerator::ActionViewStrategy.new
end 
```

### I18nStrategy

To use Rails specific strategies you must first `require 'crystalball/rails'`.
Patches I18n to have access to the path where the locales are defined, so that those paths can be added to the example group map.
To use it, add to your config:

```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::MapGenerator::I18nStrategy.new
end
```

### FactoryBotStrategy

Tracks which factories were used during the example and add files with corresponding definitions to the example group map.
To use it, add to your config:
```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.register Crystalball::MapGenerator::FactoryBotStrategy.new
end
```

### Custom strategies

You can create your own strategy and use it with the map generator. Any object that responds to `#call(example_group_map, example)` (where `example_group_map` is a `Crystalball::ExampleGroupMap` and `example` a `RSpec::Core::Example`) and augmenting its list of used files using `example_group_map.push(*paths_to_files)`.
Check out the [implementation](https://github.com/toptal/crystalball/tree/master/lib/crystalball/map_generator) of the default strategies for examples.

Keep in mind that all the strategies configured for the map generator will run for each example of your test suite, so it may slow down the generation process considerably.

### Debugging

By default MapGenerator generates compact map. In case you need plain and easily readable map add to your config:
```ruby
Crystalball::MapGenerator.start! do |config|
  #...
  config.compact_map = false
end
``` 

## TablesMapGenerator

TablesMapGenerator is a separate map generator for Rails applications. It collects information about tables-to-models mapping and stores it in a file. The file is used by `Crystalball::Rails::Predictor::ModifiedSchema`.
Use `Crystalball::Rails::TablesMapGenerator.start!` to start it.

By default TablesMapGenerator will generate `tables_map.yml` file. You can customize this behavior by setting `map_storage_path` variable:
```ruby
Crystalball::TablesMapGenerator.start! do |config|
  #...
  config.map_storage_path = 'my_custom_tables_map_name.yml'
end
```


