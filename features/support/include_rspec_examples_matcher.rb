# frozen_string_literal: true

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

  def contexts(example_id) # rubocop:disable Metrics/MethodLength
    file_path, inner_path = split_example_id(example_id)

    contexts = [example_id, file_path]

    inner_groups = inner_path.split(':')
    until inner_groups.empty?
      inner_groups.pop
      contexts << "#{file_path}[#{inner_groups.join(':')}]"
    end

    file_path_groups = file_path.split('/')
    until file_path_groups.empty?
      file_path_groups.pop
      contexts << file_path_groups.join('/')
    end
    contexts.uniq
  end

  def split_example_id(example_id)
    if example_id.include?('[')
      /(.*)\[(.*)\]/.match(example_id)[1..-1]
    else
      [example_id, '']
    end
  end
end
