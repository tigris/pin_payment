require 'test_helper'

class TestPinBalance < MiniTest::Unit::TestCase
  def setup
    common_setup
  end

  def test_current_balance_success
    FakeWeb.register_uri(:get, 'https://test-api.pin.net.au/1/balance', body: fixtures['responses']['balance']['success'])
    assert_kind_of PinPayment::Balance, PinPayment::Balance.current_balance
  end

end
