# frozen_string_literal: true

require 'spec_helper'
require 'crystalball/map_generator/parser_strategy/processor'

RSpec.describe Crystalball::MapGenerator::ParserStrategy::Processor do
  let(:processor) { described_class.new }
  let(:path) { 'path/to/file' }

  before do
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with(path).and_return(str)
  end

  describe '#consts_defined_in' do
    subject(:consts_defined_in) { processor.consts_defined_in(path) }

    context 'when it has a simple class definition' do
      let(:str) do
        <<~STR
          require 'foo'

          class SomeClass
            def some_method(*args)
            end
          end
        STR
      end

      it 'returns the class name' do
        expect(consts_defined_in).to eq(%w[SomeClass])
      end
    end

    context 'when it has a simple module definition' do
      let(:str) do
        <<~STR
          require 'foo'

          module SomeModule
            def some_method(*args)
            end
          end
        STR
      end

      it 'returns the module name' do
        expect(consts_defined_in).to eq(%w[SomeModule])
      end
    end

    context 'when it has a nested module definition' do
      let(:str) do
        <<~STR
          require 'foo'

          module SomeModule
            module SomeOtherModule
              def some_method(*args)
              end
            end
          end
        STR
      end

      it 'returns the module name' do
        expect(consts_defined_in).to eq(%w[SomeModule SomeModule::SomeOtherModule])
      end
    end

    context 'when multiple constants are defined' do
      let(:str) do
        <<~STR
          require 'foo'

          module SomeModule
            module SomeOtherModule
              def some_method(*args)
              end
            end

            module YetAnotherModule
            end
          end
        STR
      end

      it 'returns the module name' do
        expect(consts_defined_in).to eq(%w[SomeModule SomeModule::SomeOtherModule SomeModule::YetAnotherModule])
      end
    end

    context 'when it has a namespaced module definition' do
      let(:str) do
        <<~STR
          require 'foo'

          module SomeModule::SomeOtherModule
            def some_method(*args)
            end
          end
        STR
      end

      it 'returns the module name' do
        expect(consts_defined_in).to eq(%w[SomeModule::SomeOtherModule])
      end
    end

    context 'when it has a Class.new definition' do
      let(:str) do
        <<~STR
          require 'foo'

          SomeModule::SomeClass = Class.new do
            def some_method(*args)
            end
          end
        STR
      end

      it 'returns the class name' do
        expect(consts_defined_in).to eq(%w[SomeModule::SomeClass])
      end
    end

    context 'when it has a constant assignment' do
      let(:str) do
        <<~STR
          require 'foo'

          class MyClass < Foo
            MY_CONSTANT = 3.1415
            MY_OTHER_CONSTANT = :ha
          end
        STR
      end

      it 'returns the class name' do
        expect(consts_defined_in).to eq(%w[MyClass MyClass::MY_CONSTANT MyClass::MY_OTHER_CONSTANT])
      end
    end
  end

  describe '#consts_interacted_with_in' do
    subject(:consts_interacted_with_in) { processor.consts_interacted_with_in(path) }

    context 'when the call is on the top level' do
      let(:str) do
        <<~STR
          SomeClass.method_name
        STR
      end

      it 'adds the class name' do
        expect(consts_interacted_with_in).to eq(%w[SomeClass])
      end
    end

    context 'when the call is on a class definition' do
      let(:str) do
        <<~STR
          require 'some_class'

          # comment
          class Foo
            SomeClass.method_name
            ::SomeModule::SomeOtherModule.do_stuff
          end
        STR
      end

      it 'adds the class name' do
        expect(consts_interacted_with_in).to eq(%w[SomeClass SomeModule::SomeOtherModule])
      end
    end

    context 'when a class subclasses another' do
      let(:str) do
        <<~STR
          require 'bar/some_class'

          # comment
          class Foo < Bar::SomeClass
            ::SomeModule::SomeOtherModule.do_stuff
          end
        STR
      end

      it 'adds the class name' do
        expect(consts_interacted_with_in).to eq(%w[Bar::SomeClass SomeModule::SomeOtherModule])
      end
    end
  end
end
