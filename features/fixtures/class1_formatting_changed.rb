# rubocop:disable all

class Class1






attr_reader :var

# Some coment here
def self.foo
end

          # and here
def initialize(var = 1)
@var = var
end

# and a bit of identation
              def bar
              'bar of Class1'
              end
end
