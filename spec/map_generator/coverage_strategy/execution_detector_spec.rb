# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::CoverageStrategy::ExecutionDetector do
  subject(:detector) { described_class.new(root) }
  let(:root) { '/tmp' }
  let(:before_map) { {path => [0, 2, nil]} }
  let(:after_map) { {path => [0, 3, nil]} }
  let(:path) { '/tmp/file.rb' }

  describe '#detect' do
    subject { detector.detect(before_map, after_map) }

    it { is_expected.to eq(%w[file.rb]) }

    context 'with no changes' do
      let(:after_map) { {path => [0, 2, nil]} }

      it { is_expected.to eq([]) }
    end

    context 'with path outside of root' do
      let(:path) { '/abc/file.rb' }

      it { is_expected.to eq([]) }
    end
  end
end
