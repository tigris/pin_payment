require 'test_helper'

class TestPinCharge < MiniTest::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
  end

  def test_invalid_amount
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/charges', body: fixtures['responses']['charge']['invalid_amount'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::Charge.create(customer: 'cus__03Cn1lSk3offZ0IGkwpCg', amount: 10.0)
    end
  end

  def test_successful_charge
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/charges', body: fixtures['responses']['charge']['success'])
    charge = PinPayment::Charge.create(customer: 'cus__03Cn1lSk3offZ0IGkwpCg', amount: 1000)
    assert_equal true, charge.success?
  end

  def test_create_charge_with_card_hash
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/charges', body: fixtures['responses']['charge']['create_with_card'])
    card_hash = {
      number:           5520000000000000,
      expiry_month:     5,
      expiry_year:      2014,
      cvc:              123,
      name:             'Roland Robot',
      address_line1:    '42 Sevenoaks St',
      address_city:     'Lathlain',
      address_postcode: 6454,
      address_state:    'WA',
      address_country:  'Australia'
    }
    charge = PinPayment::Charge.create(amount: 400, currency: 'AUD', description: 'test charge', email: 'roland@pin.net.au', ip_address: '203.192.1.172', card: card_hash)
    assert_equal true, charge.success?
    assert_kind_of PinPayment::Card, charge.card
    assert_kind_of String, charge.card.token
    assert charge.card.token.length > 0
  end

  def test_fetch_all_charges
    FakeWeb.register_uri(:get, 'https://test-api.pin.net.au/1/charges', body: fixtures['responses']['charge']['all'])
    charges = PinPayment::Charge.all
    assert_equal 2, charges.length
    assert_kind_of PinPayment::Charge, charges.first
  end
end
