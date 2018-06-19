# frozen_string_literal: true

require 'rails_helper'

describe Crystalball::Rails::TablesMap do
  subject { described_class.new }
  let(:used_files) { instance_double(Array) }

  before { allow(used_files).to receive(:uniq) { used_files } }

  describe '#clear!' do
    before { subject['dummies'] = %w[models/dummy.rb] }

    it 'wipes out all cases' do
      expect do
        subject.clear!
      end.to change { subject.cases.size }.by(-1)
    end
  end

  describe '#add files for table' do
    it do
      expect do
        subject.add(files: [1, 2, 3, 1], for_table: 'dummies')
      end.to change { subject.cases }.to('dummies' => [1, 2, 3])
    end
  end
end
