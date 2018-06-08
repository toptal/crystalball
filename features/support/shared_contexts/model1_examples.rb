# frozen_string_literal: true

shared_context 'model1 examples' do
  let(:model1_examples) do
    [
      './spec/models/model1_spec.rb[1:1:1]',
      './spec/models/model1_spec.rb[1:2:1]',
      './spec/models/model1_spec.rb[1:3:1]',
      './spec/models/model1_spec.rb[1:4:1]',
      './spec/views/index.html.erb_spec.rb[1:1]',
      './spec/views/index.html.erb_spec.rb[1:2]',
      './spec/views/index.html.erb_spec.rb[1:3]',
      './spec/views/show.html.erb_spec.rb[1:1]'
    ]
  end
end
