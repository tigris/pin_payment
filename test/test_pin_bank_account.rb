require 'test_helper'

class TestPinBankAccount < MiniTest::Unit::TestCase
  def setup
    common_setup
  end

  def test_create_with_no_name
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/bank_accounts', body: fixtures['responses']['bank_account']['missing_name'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::BankAccount.create({bsb: "123123", number: "123456789"})
    end
  end

  def test_create_with_no_bsb
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/bank_accounts', body: fixtures['responses']['bank_account']['missing_bsb'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::BankAccount.create({name: "Test Account", number: "123456789"})
    end
  end

  def test_create_with_no_number
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/bank_accounts', body: fixtures['responses']['bank_account']['missing_number'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::BankAccount.create({name: "Test Account", number: "123456789"})
    end
  end

  def test_create_success
    bank_account = created_bank_account
    assert_kind_of PinPayment::BankAccount, bank_account
  end

end
