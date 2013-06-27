require 'test_helper'

class TestPinRefund < MiniTest::Unit::TestCase
  def setup
    common_setup
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/charges', body: fixtures['responses']['charge']['success'])
    @charge = PinPayment::Charge.create(charge_hash)
  end

  def test_duplicate_refund
    FakeWeb.register_uri(:post, "https://test-api.pin.net.au/1/charges/#{@charge.token}/refunds", body: fixtures['responses']['refund']['success'])
    PinPayment::Refund.create(@charge)
    FakeWeb.register_uri(:post, "https://test-api.pin.net.au/1/charges/#{@charge.token}/refunds", body: fixtures['responses']['refund']['duplicate'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::Refund.create(@charge)
    end
  end

  def test_direct_refund
    FakeWeb.register_uri(:post, "https://test-api.pin.net.au/1/charges/#{@charge.token}/refunds", body: fixtures['responses']['refund']['success'])
    refund = PinPayment::Refund.create(@charge.token)
    assert_equal 'Pending', refund.status
  end

  def test_object_refund
    FakeWeb.register_uri(:post, "https://test-api.pin.net.au/1/charges/#{@charge.token}/refunds", body: fixtures['responses']['refund']['success'])
    refund = @charge.refund!
    assert_equal 'Pending', refund.status
  end
end
