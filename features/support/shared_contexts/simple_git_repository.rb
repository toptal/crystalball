# frozen_string_literal: true

shared_context 'simple git repository' do
  let(:features_root) { Pathname(__dir__).join('..', '..', '..', 'features') }
  let(:fixtures_path) { features_root.join('fixtures') }
  let(:simple_app_path) { fixtures_path.join('simple_app') }
  let(:tmp_path) { features_root.join('tmp') }
  let(:root) { tmp_path.join('simple_app') }
  let(:lib_path) { root.join('lib') }
  let(:class1_path) { lib_path.join('class1.rb') }
  let(:class2_path) { lib_path.join('class2.rb') }
  let(:model1_path) { root.join('models', 'model1.rb') }
  let(:spec_path) { root.join('spec') }
  let(:class1_spec_path) { spec_path.join('class1_spec.rb') }
  let(:action_view_shared_context) { spec_path.join('support', 'shared_contexts', 'action_view.rb') }
  let(:git) { Git.init(root.to_s) }
  let(:spec_helper) { File.join(root, 'spec/spec_helper.rb') }

  # By default, generate map with metadata only
  let(:map_generator_config) do
    <<~CONFIG
      Crystalball::MapGenerator.start! do |c|
      end
    CONFIG
  end

  before do
    tmp_path.mkpath
    FileUtils.cp_r(simple_app_path, tmp_path)

    git.add(all: true)
    git.commit('First commit')

    raise "Can't generate map" unless generate_map
  end

  after do
    root.rmtree
  end

  def generate_map
    replace_spec_helper_config
    system("cd #{root} && rspec spec > /dev/null")
  end

  def change(file_path, content = '"changed"')
    file_path.write(content)
  end

  def delete(file_path)
    git.lib.remove file_path
  end

  def move(file_path)
    move_path = file_path.dirname.join("moved_#{file_path.basename}")
    git.lib.mv(file_path, move_path)
    move_path
  end

  def self.map_generator_config(&block)
    let(:map_generator_config, &block)
  end

  private

  def replace_spec_helper_config
    config = map_generator_config.to_s.chomp
    replace(spec_helper, /# MAP_GENERATOR_CONFIG/, config)
    git.commit_all('Update spec helper')
  end

  def replace(filepath, regexp, *args, &block)
    content = File.read(filepath).gsub(regexp, *args, &block)
    File.open(filepath, 'wb') { |file| file.write(content) }
  end
end
