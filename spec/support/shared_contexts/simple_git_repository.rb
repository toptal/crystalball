# frozen_string_literal: true

shared_context 'simple git repository' do
  let(:features_root) { Pathname(__dir__).join('..', '..', '..', 'features') }
  let(:simple_app_path) { features_root.join('fixtures', 'simple_app') }
  let(:tmp_path) { features_root.join('tmp') }
  let(:root) { tmp_path.join('simple_app') }
  let(:lib_path) { root.join('lib') }
  let(:spec_path) { root.join('spec') }
  let(:class1_path) { lib_path.join('class1.rb') }
  let(:class2_path) { lib_path.join('class2.rb') }
  let(:class_eval_include_path) { lib_path.join('class_eval_include.rb') }
  let(:class_eval_extend_path) { lib_path.join('class_eval_extend.rb') }
  let(:model1_path) { root.join('models', 'model1.rb') }
  let(:item_view_path) { root.join('views', '_item.html.erb') }
  let(:module1_path) { lib_path.join('module1.rb') }
  let(:class1_spec_path) { spec_path.join('class1_spec.rb') }
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
end
