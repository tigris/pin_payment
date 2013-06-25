require 'test_helper'

class TestPinCharge < MiniTest::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
  end

  def test_invalid_amount
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/charges', body: fixtures['responses']['charge']['invalid_amount'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::Charge.create(customer_token: 'cus__03Cn1lSk3offZ0IGkwpCg', amount: 10.0)
    end
  end

  def test_successful_charge
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/charges', body: fixtures['responses']['charge']['success'])
    charge = PinPayment::Charge.create(customer_token: 'cus__03Cn1lSk3offZ0IGkwpCg', amount: 1000)
    assert_equal true, charge.success?
  end
end
