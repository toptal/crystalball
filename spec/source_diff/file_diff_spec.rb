# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::SourceDiff::FileDiff do
  subject(:file_diff) { described_class.new(diff_file) }
  let(:diff_file) { Git::Diff::DiffFile.new(Git::Base.new, type: type, path: 'lib/crystalball.rb') }
  let(:type) {}

  %i[modified deleted new].each do |type|
    context "##{type}?" do
      subject { file_diff.send("#{type}?") }

      it { is_expected.to be_falsey }

      context 'with correct type' do
        let(:type) { type.to_s }

        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#relative_path' do
    subject { file_diff.relative_path }
    it { is_expected.to eq('lib/crystalball.rb') }
  end

  describe '#method_missing' do
    it 'delegates missing methods to DiffFile' do
      expect(file_diff.path).to eq('lib/crystalball.rb')
      expect(file_diff.method(:path).call).to eq('lib/crystalball.rb')
    end
  end
end
