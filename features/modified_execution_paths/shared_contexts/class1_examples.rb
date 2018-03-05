# frozen_string_literal: true

shared_context 'class1 examples' do
  let(:class1_examples) do
    [
      './spec/class1_spec.rb[1:1:1]',
      './spec/class1_spec.rb[1:1:2:1]',
      './spec/class1_spec.rb[1:1:3:1]',
      './spec/class1_spec.rb[1:1:4:1]',
      './spec/class1_spec.rb[1:2:1]',
      './spec/class1_spec.rb[1:3:1]',
      './spec/file_spec.rb[1:1]'
    ]
  end
end
