require 'test_helper'

class TestPinSetup < MiniTest::Unit::TestCase
  def test_setting_public_key
    assert_equal nil, PinPayment.public_key
    PinPayment.public_key = 'foo'
    assert_equal 'foo', PinPayment.public_key
  end

  def test_setting_secret_key
    assert_equal nil, PinPayment.secret_key
    PinPayment.secret_key = 'foo'
    assert_equal 'foo', PinPayment.secret_key
  end

  def test_api_url
    assert_equal 'https://test-api.pin.net.au', PinPayment.api_url
    PinPayment.api_url = 'foo'
    assert_equal 'foo', PinPayment.api_url
  end
end
