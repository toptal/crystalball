# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Rails::MapGenerator::ActionViewStrategy::ExecutionDetector do
  subject(:detector) { described_class.new(root) }
  let(:root) { '/tmp' }
  let(:paths) { ['/tmp/file.rb'] }

  describe '#detect' do
    subject { detector.detect(paths) }

    it { is_expected.to eq(%w[file.rb]) }

    context 'with path outside of root' do
      let(:paths) { ['/abc/file.rb'] }

      it { is_expected.to eq([]) }
    end
  end
end
