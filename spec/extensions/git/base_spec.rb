# frozen_string_literal: true

require 'spec_helper'

describe Git::Base do
  let(:repo) { Git.open('.') }

  describe '#merge_base' do
    subject { repo.merge_base('HEAD^', 'HEAD').sha }

    let(:prehead) { repo.gcommit('HEAD^').sha }

    it { is_expected.to eq prehead }
  end
end
