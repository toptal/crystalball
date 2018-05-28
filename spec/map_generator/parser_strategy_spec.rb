# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Crystalball::MapGenerator::ParserStrategy do
  subject(:strategy) { described_class.new(root, pattern: pattern) }
  let(:pattern) { // }
  let(:processor) { instance_double(Crystalball::MapGenerator::ParserStrategy::Processor) }
  let(:root) { 'foo/bar' }
  let(:files) do
    %w[
      foo/bar/something.rb
      foo/bar/something/else.rb
      foo/bar/stuff.rb
    ]
  end

  before do
    allow(Crystalball::MapGenerator::ParserStrategy::Processor).to receive(:new)
      .and_return(processor)
    allow(Pathname).to receive(:new).with(root).and_return(double(realpath: root))
    allow(Dir).to receive(:glob).with('foo/bar/**/*.rb').and_return(files)
    files.each do |file|
      allow(processor).to receive(:consts_defined_in)
        .with(file) { file.scan(/\w+(?=\.rb)/).map(&:capitalize) }
    end
  end

  describe '#after_register' do
    it 'yields back each path and constant' do
      expect { |b| strategy.after_register(&b) }.to yield_successive_args(
        ['Something', files.first],
        ['Else', files[1]],
        ['Stuff', files.last]
      )
    end

    it 'adds the constants defined to the const_definition_paths' do
      strategy.after_register
      expect(strategy.const_definition_paths).to eq(
        'Something' => %w[foo/bar/something.rb],
        'Else' => %w[foo/bar/something/else.rb],
        'Stuff' => %w[foo/bar/stuff.rb]
      )
    end

    context 'when a pattern is given' do
      let(:pattern) { /something/ }

      it 'filters the results' do
        strategy.after_register
        expect(strategy.const_definition_paths).to eq(
          'Something' => %w[foo/bar/something.rb],
          'Else' => %w[foo/bar/something/else.rb]
        )
      end
    end
  end

  describe '#call' do
    before do
      allow(processor).to receive(:consts_interacted_with_in)
        .with('some_dir/some_file.rb')
        .and_return('Something')
    end

    it 'adds the definition file to the map' do
      strategy.after_register
      case_map = %w[some_dir/some_file.rb]
      strategy.call(case_map) {}
      expect(case_map).to match_array(%w[some_dir/some_file.rb something.rb])
    end
  end
end
