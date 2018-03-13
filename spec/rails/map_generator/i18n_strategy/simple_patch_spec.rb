# frozen_string_literal: true

require 'rails_helper'

describe Crystalball::Rails::MapGenerator::I18nStrategy::SimplePatch do
  subject(:instance) do
    Class.new do
      include Crystalball::Rails::MapGenerator::I18nStrategy::SimplePatch

      def cb_original_load_file(*args); end

      def cb_original_store_translations(*args); end

      def cb_original_lookup(*args); end
    end.new
  end

  context 'I18n::Backend::Simple patching' do
    before do
      stub_const(
        '::I18n',
        Class.new do
          def self.reload!; end
        end
      )

      stub_const(
        '::I18n::Backend::Simple',
        Class.new do
          def load_file; end

          def store_translations; end

          def lookup; end
        end
      )
    end

    let!(:patched_class) { ::I18n::Backend::Simple }

    %i[load_file store_translations lookup].each do |method|
      it "changes and restores #{method} method" do
        original_method = patched_class.instance_method(method)
        described_class.apply!
        expect(patched_class.instance_method(method)).not_to eq original_method
        expect(I18n).to receive(:reload!)
        described_class.revert!
        expect(patched_class.instance_method(method)).to eq original_method
      end
    end
  end

  describe '#cb_patched_load_file' do
    subject { instance.cb_patched_load_file(filename) }

    let(:filename) { 'locale/foo.yml' }

    it do
      expect(instance).to receive(:cb_original_load_file).with(filename)
      expect(Thread.current).to receive(:[]=).with(:cb_locale_file_name, filename)
      subject
    end
  end

  describe '#cb_patched_store_translations' do
    subject { instance.cb_patched_store_translations(locale, data) }
    let(:locale) { :en }
    let(:data) { {user: {name: 'John'}} }
    let(:filename) { 'locale/foo.yml' }

    before { allow(Thread.current).to receive(:[]).with(:cb_locale_file_name) { filename } }

    it do
      expect(instance).to receive(:cb_original_store_translations).with(locale, user: {name: {cb_filename: filename, cb_value: 'John'}})
      subject
    end
  end

  describe '#cb_patched_lookup' do
    subject { instance.cb_patched_lookup(args) }
    let(:args) { 'some' }
    let(:locale_files) { [] }

    before { allow(Crystalball::Rails::MapGenerator::I18nStrategy).to receive(:locale_files) { locale_files } }

    context 'for completely resolved value' do
      let(:value) { {cb_filename: 'filename', cb_value: 'John Doe'} }

      it 'calls original and stores filename' do
        expect(instance).to receive(:cb_original_lookup).with(args) { value }
        expect { subject }.to change { locale_files }.from([]).to(['filename'])
        expect(subject).to eq('John Doe')
      end
    end

    context 'for hash value' do
      let(:value) { {scope: {cb_filename: 'filename', cb_value: 'John Doe'}} }

      it 'calls original and stores filename' do
        expect(instance).to receive(:cb_original_lookup).with(args) { value }
        expect { subject }.to change { locale_files }.from([]).to(['filename'])
        expect(subject).to eq(scope: 'John Doe')
      end
    end
  end
end
