require 'test_helper'

class TestPinCustomer < MiniTest::Unit::TestCase
  def setup
    common_setup
  end

  def test_create_with_blank_email
    FakeWeb.register_uri(:post, 'https://test-api.pinpayments.com/1/customers', body: fixtures['responses']['customer']['blank_email'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::Customer.create(email: nil, card: card_hash)
    end
  end

  def test_create_success
    customer = created_customer
    assert_kind_of PinPayment::Customer, customer
  end
  
  def test_delete_success
  	customer = created_customer
    FakeWeb.register_uri(:delete, "https://test-api.pinpayments.com/1/customers/#{customer.token}", body: fixtures['responses']['customer']['deleted'])
    response = PinPayment::Customer.delete_customer(customer.token)
    assert_empty response
  end
  
  def test_delete_not_found
  	token = 'none-existing-token'
    FakeWeb.register_uri(:delete, "https://test-api.pinpayments.com/1/customers/#{token}", body: fixtures['responses']['customer']['delete_not_found'])
    assert_raises PinPayment::Error::ResourceNotFound do
      PinPayment::Customer.delete_customer(token)
    end
  end

  def test_direct_update
    customer = created_customer
    FakeWeb.register_uri(:put, "https://test-api.pinpayments.com/1/customers/#{customer.token}", body: fixtures['responses']['customer']['updated'])
    customer = PinPayment::Customer.update(customer.token, 'changed@example.com')
    assert_equal 'changed@example.com', customer.email
  end

  def test_object_update
    customer = created_customer
    FakeWeb.register_uri(:put, "https://test-api.pinpayments.com/1/customers/#{customer.token}", body: fixtures['responses']['customer']['updated'])
    customer.update('changed@example.com')
    assert_equal 'changed@example.com', customer.email
  end

  def test_find_customer
    customer = created_customer
    FakeWeb.register_uri(:get, "https://test-api.pinpayments.com/1/customers/#{customer.token}", body: fixtures['responses']['customer']['created'])
    customer = PinPayment::Customer.find(customer.token)
    assert_kind_of PinPayment::Customer, customer
  end

  def test_fetch_all_customers
    FakeWeb.register_uri(:get, 'https://test-api.pinpayments.com/1/customers', body: fixtures['responses']['customer']['all'])
    customers = PinPayment::Customer.all
    assert_kind_of Array, customers
    assert_kind_of PinPayment::Customer, customers.first
  end

  def test_create_customer_with_card_hash
    FakeWeb.register_uri(:post, 'https://test-api.pinpayments.com/1/customers', body: fixtures['responses']['customer']['create_with_card'])
    customer = PinPayment::Customer.create('roland@pinpayments.com', card_hash)
    assert_kind_of PinPayment::Card, customer.card
    assert_kind_of String, customer.card.token
    assert customer.card.token.length > 0
  end
end
