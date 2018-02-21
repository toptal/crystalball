# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::MapGenerator::Helpers::PathFilter do
  subject(:helper) { Class.new.tap { |c| c.include described_class }.new(root) }
  let(:root) { '/foo' }
  let(:paths) { ['/foo/file.rb', '/abc/file1.rb'] }

  describe '#filter' do
    subject { helper.filter(paths) }

    it 'takes paths relative too root only' do
      is_expected.to eq(%w[file.rb])
    end
  end
end
