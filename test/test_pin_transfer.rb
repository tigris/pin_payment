require 'test_helper'

class TestPinTransfer < MiniTest::Unit::TestCase
  def test_transfer_create
    transfer = created_transfer
    assert_kind_of PinPayment::Transfer, transfer
  end

  def test_fetch_all_transfers
    FakeWeb.register_uri(:get, 'https://test-api.pin.net.au/1/transfers', body: fixtures['responses']['transfer']['all'])
    transfers = PinPayment::Transfer.all
    assert_kind_of Array, transfers
    assert_kind_of PinPayment::Transfer, transfers.first
  end

  def test_find_transfer
    transfer = created_transfer
    FakeWeb.register_uri(:get, "https://test-api.pin.net.au/1/transfers/#{transfer.token}", body: fixtures['responses']['transfer']['created'])
    transfer = PinPayment::Transfer.find(transfer.token)
    assert_kind_of PinPayment::Transfer, transfer
  end

  def test_line_items
    transfer = created_transfer
    FakeWeb.register_uri(:get, "https://test-api.pin.net.au/1/transfers/#{transfer.token}/line_items", body: fixtures['responses']['line_item']['all'])
    line_items = transfer.line_items
    assert_kind_of Array, line_items
    assert_kind_of PinPayment::Transfer::LineItem, line_items.first
  end

end
