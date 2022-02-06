# frozen_string_literal: true

require 'test_helper'

class TestIpgeobase < Minitest::Test
  def test_that_it_has_a_version
    refute_nil ::Ipgeobase::VERSION
  end
end
