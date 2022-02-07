# frozen_string_literal: true

require 'test_helper'

class TestIpgeobase < Minitest::Test
  TEST_ERRORS = [
    { message: 'code: 500, message: Internal Server Error', to_return: [500, 'Internal Server Error'] },
    { message: 'code: 500, message: HTTPInternalServerError', to_return: 500 },
    { message: 'code: 400, message: Bad Request', to_return: [400, 'Bad Request'] },
    { message: 'code: 400, message: HTTPBadRequest', to_return: 400 }
  ].freeze

  TEST_DATA = {
    city: 'Ashburn',
    country: 'United States',
    countryCode: 'US',
    lat: 39.03,
    lon: -77.5
  }.freeze

  def before_setup
    @ip   = '8.8.8.8'
    @stub = stub_request(:get, "http://ip-api.com/xml/#{@ip}")
  end

  def test_that_it_has_a_version
    refute_nil ::Ipgeobase::VERSION
  end

  def test_with_stub
    @stub.to_return(status: 200, body: File.read('./test/fixtures/8_8_8_8.xml'))
    ip_meta = Ipgeobase.lookup(@ip)

    assert ip_meta.instance_of?(Ipgeobase::Metadata)
    TEST_DATA.each { |name, value| assert_equal(ip_meta.send(name), value) }
  end

  def test_with_request
    WebMock.disable!
    ip_meta = Ipgeobase.lookup(@ip)

    assert ip_meta.instance_of?(Ipgeobase::Metadata)
    TEST_DATA.each { |name, value| assert_equal(ip_meta.send(name), value) }
    WebMock.enable!
  end

  def test_errors
    TEST_ERRORS.each do |param|
      @stub.to_return(status: param[:to_return])
      error = assert_raises(Ipgeobase::Error) { raise Ipgeobase.lookup(@ip) }

      assert error.instance_of?(Ipgeobase::Error)
      assert_equal(param[:message], error.message)
    end
  end

  def test_timeout_error_in_resque
    @stub.to_timeout

    error = assert_raises(Ipgeobase::Error) { raise Ipgeobase.lookup(@ip) }
    assert_equal('execution expired', error.message)
  end

  def test_another_error_in_resque
    @stub.to_raise('Some error')

    error = assert_raises(Ipgeobase::Error) { raise Ipgeobase.lookup(@ip) }
    assert_equal('Some error', error.message)
  end
end
