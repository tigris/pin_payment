require 'test_helper'

class TestPinRecipient < MiniTest::Unit::TestCase
  def setup
    common_setup
  end

  def test_create_with_blank_email
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/recipients', body: fixtures['responses']['recipient']['blank_email'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::Recipient.create({email: nil, name: "Test Name", bank_account: bank_account_hash})
    end
  end

  def test_create_success
    recipient = created_recipient
    assert_kind_of PinPayment::Recipient, recipient
  end

  def test_direct_update
    recipient = created_recipient
    FakeWeb.register_uri(:put, "https://test-api.pin.net.au/1/recipients/#{recipient.token}", body: fixtures['responses']['recipient']['updated'])
    recipient = PinPayment::Recipient.update(recipient.token, 'changed@example.com')
    assert_equal 'changed@example.com', recipient.email
  end

  def test_object_update
    recipient = created_recipient
    FakeWeb.register_uri(:put, "https://test-api.pin.net.au/1/recipients/#{recipient.token}", body: fixtures['responses']['recipient']['updated'])
    recipient.update('changed@example.com')
    assert_equal 'changed@example.com', recipient.email
  end

  def test_find_recipient
    recipient = created_recipient
    FakeWeb.register_uri(:get, "https://test-api.pin.net.au/1/recipients/#{recipient.token}", body: fixtures['responses']['recipient']['created'])
    recipient = PinPayment::Recipient.find(recipient.token)
    assert_kind_of PinPayment::Recipient, recipient
  end

  def test_fetch_all_recipients
    FakeWeb.register_uri(:get, 'https://test-api.pin.net.au/1/recipients', body: fixtures['responses']['recipient']['all'])
    recipients = PinPayment::Recipient.all
    assert_kind_of Array, recipients
    assert_kind_of PinPayment::Recipient, recipients.first
  end

  def test_create_recipient_with_bank_account_hash
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/recipients', body: fixtures['responses']['recipient']['create_with_bank_account'])
    data = {
      email: 'foo@example.com',
      name: 'Test User',
      bank_account: bank_account_hash
    }
    recipient = PinPayment::Recipient.create(data)
    assert_kind_of PinPayment::BankAccount, recipient.bank_account
    assert_kind_of String, recipient.bank_account.token
    assert recipient.bank_account.token.length > 0
  end
end
