require 'test_helper'

class TestPinCard < MiniTest::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
    @card_hash = {
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
  end

  def test_successful_card
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/cards', body: fixtures['responses']['card']['success'])
    card = PinPayment::Card.create(@card_hash)
    assert_equal 'card_nytGw7koRg23EEp9NTmz9w', card.token
    assert_equal 'XXXX-XXXX-XXXX-0000', card.display_number
    assert_equal 'master', card.scheme
  end

  def test_invalid_card
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/cards', body: fixtures['responses']['card']['invalid'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::Card.create(@card_hash.merge(number: 5520000000000099))
    end
  end
end
