# frozen_string_literal: true

require 'rails_helper'

describe Crystalball::Rails::TablesMap do
  subject { described_class.new }
  let(:affected_files) { instance_double(Array) }

  before { allow(affected_files).to receive(:uniq) { affected_files } }

  describe '#clear!' do
    it 'wipes out all cases' do
      subject['dummies'] = %w[models/dummy.rb]
      expect do
        subject.clear!
      end.to change { subject.cases.size }.by(-1)
    end
  end
end
