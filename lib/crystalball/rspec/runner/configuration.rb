module Crystalball
  module RSpec
    class Runner
      # Class for storing local runner configuration
      class Configuration
        def initialize(config = {})
          @values = {
            'map_path' => 'tmp/execution_maps',
            'map_expiration_period' => 86_400,
            'repo_path' => Dir.pwd,
            'predictor_class_name' => 'Crystalball::Predictor',
            'requires' => [],
            'diff_from' => 'HEAD',
            'diff_to' => nil,
            'runner_class_name' => 'Crystalball::RSpec::Runner'
          }.merge(config)
        end

        def to_h
          dynamic_values = {}
          (private_methods - Object.private_instance_methods - %i[run_requires values]).each do |method|
            dynamic_values[method.to_s] = send(method)
          end

          values.merge(dynamic_values)
        end

        def [](key)
          respond_to?(key, true) ? send(key) : values[key]
        end

        private

        def predictor_class
          @predictor_class ||= begin
            run_requires

            Object.const_get(self['predictor_class_name'])
          end
        end

        def runner_class
          @runner_class ||= begin
            run_requires

            Object.const_get(self['runner_class_name'])
          end
        end

        def map_path
          @map_path ||= Pathname.new(values['map_path'])
        end

        def repo_path
          @repo_path ||= Pathname.new(values['repo_path'])
        end

        attr_reader :values

        def run_requires
          self['requires'].each { |f| require f }
        end
      end
    end
  end
end
