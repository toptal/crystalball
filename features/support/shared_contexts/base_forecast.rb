# frozen_string_literal: true

shared_context 'base forecast' do
  subject(:forecast) { predictor.prediction.compact }
  let(:predictor) do
    Crystalball::Predictor.new(map, repo, from: map.commit) do |predictor|
      strategies.each { |strategy| predictor.use strategy }
    end
  end
  let(:strategies) { [] } # to be overriden
  let(:map) { Crystalball::MapStorage::YAMLStorage.load(Pathname.new(root.join('execution_map.yml'))) }
  let(:repo) { Crystalball::GitRepo.open(Pathname.new(workdir)) }
  let(:workdir) { root }
end
