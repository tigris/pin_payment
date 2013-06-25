require 'test_helper'

class TestPinRefund < MiniTest::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
  end

  def test_duplicate_refund
    token = 'ch_BjGW-S6WUisI6mOgpDRimg'
    FakeWeb.register_uri(:post, "https://test-api.pin.net.au/1/charges/#{token}/refunds", body: fixtures['responses']['refund']['duplicate'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::Refund.create(charge_token: token)
    end
  end

  def test_direct_refund
    token = 'ch_BjGW-S6WUisI6mOgpDRimg'
    FakeWeb.register_uri(:post, "https://test-api.pin.net.au/1/charges/#{token}/refunds", body: fixtures['responses']['refund']['success'])
    refund = PinPayment::Refund.create(charge_token: token)
    assert_equal 'Pending', refund.status
  end

  def test_object_refund
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/charges', body: fixtures['responses']['charge']['success'])
    charge = PinPayment::Charge.create(customer_token: 'cus__03Cn1lSk3offZ0IGkwpCg', amount: 1000)

    FakeWeb.register_uri(:post, "https://test-api.pin.net.au/1/charges/#{charge.token}/refunds", body: fixtures['responses']['refund']['success'])
    refund = charge.refund!
    assert_equal 'Pending', refund.status
  end
end
