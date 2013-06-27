require 'test_helper'

class TestPinCard < MiniTest::Unit::TestCase
  def setup
    common_setup
  end

  def test_successful_card
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/cards', body: fixtures['responses']['card']['success'])
    card = PinPayment::Card.create(card_hash)
    assert_equal 'XXXX-XXXX-XXXX-0000', card.display_number
    assert_equal 'master', card.scheme
  end

  def test_invalid_card
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/cards', body: fixtures['responses']['card']['invalid'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::Card.create(card_hash.merge(number: 5520000000000099))
    end
  end

  def test_new_from_hash
    card = PinPayment::Card.new(nil, card_hash)
    assert_kind_of PinPayment::Card, card
  end

  def test_to_hash
    card = PinPayment::Card.new(nil, card_hash)
    assert_kind_of Hash, card.to_hash
  end
end
