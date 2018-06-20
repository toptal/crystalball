# frozen_string_literal: true

require 'spec_helper'
require 'crystalball/factory_bot'

describe Crystalball::MapGenerator::FactoryBotStrategy::FactoryGemLoader do
  describe '.require!' do
    subject { described_class.require! }

    it do
      expect(described_class).to receive(:require).with('factory_bot')
      subject
    end

    it do
      allow(described_class).to receive(:require).with('factory_bot').and_raise(LoadError)
      expect(described_class).to receive(:require).with('factory_girl')
      subject
    end

    it do
      allow(described_class).to receive(:require).with('factory_bot').and_raise(LoadError)
      allow(described_class).to receive(:require).with('factory_girl').and_raise(LoadError)
      expect { subject }.to raise_error(LoadError, "Can't load `factory_bot` or `factory_girl`")
    end
  end
end
