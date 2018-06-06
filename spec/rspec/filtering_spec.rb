# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::RSpec::Filtering do
  describe '.remove_unnecessary_filters' do
    subject(:remove_unnecessary_filters) { described_class.remove_unnecessary_filters(config, files) }
    let(:filter_manager) { instance_double('RSpec::Core::FilterManager', inclusions: inclusions) }
    let(:inclusions) { {ids: double} }
    let(:nested_files) { [] }
    let(:config) do
      instance_double(
        'RSpec::Core::Configuration',
        filter_manager: filter_manager,
        gather_directories: nested_files
      ).as_null_object
    end

    context 'when the same file is passed with and without an id' do
      let(:files) { %w[./spec/foo_spec.rb ./spec/foo_spec.rb[1:1]] }

      it 'removes the filters' do
        expect(inclusions[:ids]).to receive(:delete).with('./spec/foo_spec.rb')
        remove_unnecessary_filters
      end
    end

    context 'when a file is passed with different ids' do
      let(:files) { %w[./spec/foo_spec.rb[1:2:1] ./spec/foo_spec.rb[1:1]] }

      it 'does not remove the filters' do
        expect(inclusions[:ids]).not_to receive(:delete)
        remove_unnecessary_filters
      end
    end

    context 'when a nested spec is passed with and without ids' do
      let(:files) { %w[./spec/foo/bar_spec.rb ./spec/foo/bar_spec.rb[1:1]] }

      it 'removes the filters for the file' do
        expect(inclusions[:ids]).to receive(:delete).with('./spec/foo/bar_spec.rb')
        remove_unnecessary_filters
      end
    end

    context 'when a dir is passed' do
      let(:files) { %w[./spec/foo/ ./spec/foo/bar_spec.rb[1:1]] }
      let(:nested_files) { %w[./spec/foo/bar_spec.rb] }

      before do
        allow(File).to receive(:directory?).and_return(false)
        allow(File).to receive(:directory?).with('./spec/foo/').and_return(true)
      end

      it 'removes the filters for the nested files' do
        expect(inclusions[:ids]).to receive(:delete).with('./spec/foo/bar_spec.rb')
        remove_unnecessary_filters
      end
    end
  end
end
