require 'test_helper'

class TestPinSetup < MiniTest::Unit::TestCase
  def test_setting_public_key
    assert_equal nil, Pin.public_key
    Pin.public_key = 'foo'
    assert_equal 'foo', Pin.public_key
  end

  def test_setting_secret_key
    assert_equal nil, Pin.secret_key
    Pin.secret_key = 'foo'
    assert_equal 'foo', Pin.secret_key
  end

  def test_api_url
    assert_equal 'https://test-api.pin.net.au', Pin.api_url
    Pin.api_url = 'foo'
    assert_equal 'foo', Pin.api_url
  end
end
