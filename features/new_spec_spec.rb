# frozen_string_literal: true

require_relative '../spec/spec_helper'

describe 'new spec file' do
  subject(:forecast) do
    Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) do |predictor|
      predictor.use Crystalball::Predictor::ModifiedSpecs.new
    end
  end

  include_context 'simple git repository'

  context 'adds new spec file to map' do
    before do
      new_spec_path = spec_path.join('new_spec.rb')
      new_spec_path.open('w') { |f| f.write(<<~RUBY) }
        require 'spec_helper'

        describe 'new spec' do
          specify { expect(Class1.new).not_to be_nil }
        end
      RUBY
      git.add(new_spec_path.to_s)
    end

    it { is_expected.to match_array(%w[spec/new_spec.rb]) }

    context 'and commits it' do
      subject do
        Crystalball::Predictor.new(root.join('execution_map.yml'), source_diff).tap do |predictor|
          predictor.use Crystalball::Predictor::ModifiedSpecs.new
        end.cases
      end

      let(:source_diff) { repository.diff(*repository.log.map(&:sha).reverse) }
      let(:repository) { Crystalball::GitRepo.open root }

      before do
        git.commit('second commit')
      end

      it { is_expected.to match_array(%w[spec/new_spec.rb]) }
    end
  end
end
