# frozen_string_literal: true

require_relative '../spec/spec_helper'

describe 'rename diff' do
  subject(:forecast) { Crystalball.foresee(workdir: root, map_path: root.join('execution_map.yml')) }
  include_context 'simple git repository'

  it 'generates map if Class1 file is renamed' do
    move_path = lib_path.join('my_class.rb')
    git.lib.mv(class1_path, move_path)

    is_expected.to eq(%w[./spec/file_spec.rb:6])
  end
end
