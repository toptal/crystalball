# frozen_string_literal: true

# Mock for ActiveRecord
module ActiveRecord
  # Mock for ActiveRecord::Base
  class Base
    class << self
      attr_accessor :table_name
    end
  end

  # Mock for ActiveRecord::Schema
  class Schema
    def self.define(*_); end
  end
end
