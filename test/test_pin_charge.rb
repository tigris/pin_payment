require 'test_helper'

class TestPinCharge < MiniTest::Unit::TestCase
  def setup
    common_setup
  end

  def test_invalid_amount
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/charges', body: fixtures['responses']['charge']['invalid_amount'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::Charge.create(charge_hash.merge(amount: 10.1))
    end
  end

  def test_successful_charge
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/charges', body: fixtures['responses']['charge']['success'])
    charge = PinPayment::Charge.create(charge_hash)
    assert_equal true, charge.success?
  end

  def test_create_charge_with_card_hash
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/charges', body: fixtures['responses']['charge']['create_with_card'])
    charge = PinPayment::Charge.create(charge_hash)
    assert_equal true, charge.success?
    assert_kind_of PinPayment::Card, charge.card
    assert_kind_of String, charge.card.token
    assert charge.card.token.length > 0
  end

  def test_fetch_all_charges
    FakeWeb.register_uri(:get, 'https://test-api.pin.net.au/1/charges', body: fixtures['responses']['charge']['all'])
    charges = PinPayment::Charge.all
    assert_kind_of Array, charges
    assert_kind_of PinPayment::Charge, charges.first
  end
end
