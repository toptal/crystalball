# frozen_string_literal: true

shared_context 'simple git repository' do
  let(:features_root) { Pathname(__dir__).join('..', '..', '..', 'features') }
  let(:fixtures_path) { features_root.join('fixtures') }
  let(:simple_app_path) { fixtures_path.join('simple_app') }
  let(:tmp_path) { features_root.join('tmp') }
  let(:root) { tmp_path.join('simple_app') }
  let(:lib_path) { root.join('lib') }
  let(:class1_path) { lib_path.join('class1.rb') }
  let(:class1_reopen_path) { lib_path.join('class1_reopen.rb') }
  let(:class2_path) { lib_path.join('class2.rb') }
  let(:class2_eval_path) { lib_path.join('class2_eval.rb') }
  let(:module1_path) { lib_path.join('module1.rb') }
  let(:module2_path) { lib_path.join('module2.rb') }
  let(:model1_path) { root.join('models', 'model1.rb') }
  let(:locales_path) { root.join('locales') }
  let(:name_locale_path) { locales_path.join('name.yml') }
  let(:value_locale_path) { locales_path.join('value.yml') }
  let(:item_view_path) { root.join('views', '_item.html.erb') }
  let(:schema_path) { root.join('db', 'schema.rb') }
  let(:spec_path) { root.join('spec') }
  let(:class1_spec_path) { spec_path.join('class1_spec.rb') }
  let(:action_view_shared_context) { spec_path.join('support', 'shared_contexts', 'action_view.rb') }
  let(:git) { Git.init(root.to_s) }

  before do
    tmp_path.mkpath
    FileUtils.cp_r(simple_app_path, tmp_path)

    git.add(all: true)
    git.commit('First commit')

    raise "Can't generate map" unless system("cd #{root} && rspec spec > /dev/null") # Generate crystalball map
  end

  after do
    root.rmtree
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
end
