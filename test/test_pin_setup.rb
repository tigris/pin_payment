require 'test_helper'

class TestPinSetup < MiniTest::Unit::TestCase
  def test_setting_public_key
    oldpublic = PinPayment.public_key
    assert_nil PinPayment.public_key
    PinPayment.public_key = 'foo'
    assert_equal 'foo', PinPayment.public_key
    PinPayment.public_key = oldpublic
  end

  def test_setting_secret_key
    oldsecret = PinPayment.secret_key
    assert_nil PinPayment.secret_key
    PinPayment.secret_key = 'foo'
    assert_equal 'foo', PinPayment.secret_key
    PinPayment.secret_key = oldsecret
  end

  def test_api_url
    oldurl = PinPayment.api_url
    assert_equal 'https://test-api.pinpayments.com', PinPayment.api_url
    PinPayment.api_url = 'foo'
    assert_equal 'https://foo', PinPayment.api_url
    PinPayment.api_url = oldurl
  end
end
