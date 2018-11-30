RSpec::Matchers.define :include_rspec_examples do |*expected|
  match do |actual|
    !expected.empty? && expected.all? do |expected_example|
      include_rspec?(expected_example, actual)
    end
  end

  failure_message do |actual|
    not_included_examples = expected.reject { |e| include_rspec?(e, actual) }
    "expected #{actual} to include #{expected}.\n #{not_included_examples} where not included."
  end

  description do
    "include specified examples"
  end

  def include_rspec?(expected, actual)
    contexts(expected).any? { |ec| actual.include?(ec) }
  end

  def contexts(example_id)
    if example_id.include?('[')
      file_path, inner_path = /(.*)\[(.*)\]/.match(example_id)[1..-1]
    else
      file_path = example_id
      inner_path = ''
    end

    contexts = [example_id]
    inner_groups = inner_path.split(':')

    until inner_groups.empty?
      inner_groups.pop
      contexts << "#{file_path}[#{inner_groups.join(':')}]"
    end

    file_path_groups = file_path.split('/')

    contexts << file_path
    until file_path_groups.empty?
      file_path_groups.pop
      contexts << file_path_groups.join('/')
    end
    contexts.uniq
  end

end
