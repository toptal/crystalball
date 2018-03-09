# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::ObjectSourcesDetector::HierarchyFetcher do
  subject(:fetcher) { described_class.new(stop_classes) }

  let(:stop_classes) { [] }

  describe '#ancestors_for' do
    subject { fetcher.ancestors_for(constant) }

    let(:constant) { double(ancestors: [ancestor1, ancestor3], singleton_class: double(ancestors: [ancestor2, ancestor3])) }
    let(:ancestor1) { double }
    let(:ancestor2) { double }
    let(:ancestor3) { double }

    it 'provides all ancestors' do
      expect(subject).to match_array [ancestor1, ancestor2, ancestor3]
    end

    context 'when stop classes passed' do
      let(:stop_classes) { ['Dummy'] }
      let(:ancestor3) { Dummy }

      before { stub_const('Dummy', Class.new) }

      it 'filters ancestors' do
        expect(subject).to match_array [ancestor1, ancestor2]
      end
    end
  end
end
