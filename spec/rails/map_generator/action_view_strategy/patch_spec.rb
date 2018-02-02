# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::Rails::MapGenerator::ActionViewStrategy::Patch do
  subject(:instance) do
    Class.new do
      include Crystalball::Rails::MapGenerator::ActionViewStrategy::Patch

      def old_compile!(mod); end

      def identifier
        'view'
      end
    end.new
  end

  describe '#new_compile!' do
    subject { instance.new_compile!(mod) }
    let(:mod) { 'some' }
    let(:views) { [] }

    before { allow(Crystalball::Rails::MapGenerator::ActionViewStrategy).to receive(:views) { views } }

    it do
      expect(instance).to receive(:old_compile!).with(mod)
      subject
    end
  end
end
