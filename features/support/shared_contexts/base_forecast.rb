# frozen_string_literal: true

shared_context 'base forecast' do
  subject(:forecast) { predictor.prediction.compact }
  let(:predictor) do
    Crystalball::Predictor.new(execution_map, repo, from: execution_map.commit) do |predictor|
      strategies.each { |strategy| predictor.use strategy }
    end
  end
  let(:strategies) { [] } # to be overridden
  let(:execution_map) { Crystalball::MapStorage::YAMLStorage.load(Pathname.new(root.join('tmp/crystalball_data.yml'))) }
  let(:repo) { Crystalball::GitRepo.open(Pathname.new(workdir)) }
  let(:workdir) { root }
end
