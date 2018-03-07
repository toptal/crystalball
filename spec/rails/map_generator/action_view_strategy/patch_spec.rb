# frozen_string_literal: true

require 'rails_helper'

describe Crystalball::Rails::MapGenerator::ActionViewStrategy::Patch do
  subject(:instance) do
    Class.new do
      include Crystalball::Rails::MapGenerator::ActionViewStrategy::Patch

      def cb_original_compile!(mod); end

      def identifier
        'view'
      end
    end.new
  end

  context 'ActionView::Template patching' do
    let!(:patched_class) do
      stub_const(
        '::ActionView::Template',
        Class.new do
          def compile!; end
        end
      )
    end

    it 'changes and restores compile! method' do
      original_compile = patched_class.instance_method(:compile!)
      described_class.apply!
      expect(patched_class.instance_method(:compile!)).not_to eq original_compile
      described_class.revert!
      expect(patched_class.instance_method(:compile!)).to eq original_compile
    end
  end

  describe '#cb_patched_compile!' do
    subject { instance.cb_patched_compile!(mod) }
    let(:mod) { 'some' }
    let(:views) { [] }

    before { allow(Crystalball::Rails::MapGenerator::ActionViewStrategy).to receive(:views) { views } }

    it do
      expect(instance).to receive(:cb_original_compile!).with(mod)
      expect { subject }.to change { views }.from([]).to(['view'])
    end
  end
end
