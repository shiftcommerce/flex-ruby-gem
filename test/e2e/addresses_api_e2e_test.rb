require "minitest/autorun"
module Shift
  module Test
    module E2E
      class AddressesApiTest < MiniTest::Test

        def initialize(*args)
          puts "Initialize"
          super
        end
        def setup
          puts "setup"
        end

        def test_it_does_something
          puts "it does something"
          assert_equal true, true
        end

        def test_it_does_something_else
          puts "it does something else"
          assert_equal true, true
        end
      end
    end
  end
end