# frozen_string_literal: true

require 'rails_helper'

describe Crystalball::Rails::Helpers::SchemaDefinitionParser do
  subject(:parser) { described_class.new }

  let(:schema) { <<-RUBY }
    ActiveRecord::Schema.define do
      create_table 'users', force: :cascade do |t|
        t.string 'name', null: false
      end
       add_foreign_key 'users', 'users', column: 'name'
    end
  RUBY

  describe '.parse' do
    subject { described_class.parse(schema) }

    before do
      allow(described_class).to receive(:new).and_return(parser)
    end

    it 'returns hash with schema info' do
      expect(subject).to eq(
        'users' => {
          options: [
            ['create_table', {force: :cascade}],
            ['add_foreign_key', 'users', {column: 'name'}]
          ],
          content: [
            {
              'name' => {
                options: [[:string, {null: false}]],
                content: [{}]
              }
            }
          ]
        }
      )
    end
  end
end
