# frozen_string_literal: true

shared_examples 'module1' do
  describe '#foo' do
    subject { super().foo(arg) }
    let(:arg) { nil }

    it { is_expected.to eq 'foo of Module1' }

    %w[some words here].each do |word|
      context "with arg #{word}" do
        let(:arg) { word }

        it { is_expected.to eq "foo of Module1 #{arg}" }
      end
    end
  end

  describe '#field' do
    before { subject.field = 'value' }

    it { expect(subject.field).to eq 'value' }
  end

  describe '#name' do
    subject { super().name }

    it { is_expected.to eq name }
  end
end
