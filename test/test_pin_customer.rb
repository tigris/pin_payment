require 'test_helper'

class TestPinCustomer < MiniTest::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
  end

  def test_update_with_blank_email
    FakeWeb.register_uri(:put, 'https://test-api.pin.net.au/1/customers/cus__03Cn1lSk3offZ0IGkwpCg', body: fixtures['responses']['customer']['blank_email'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::Customer.update('cus__03Cn1lSk3offZ0IGkwpCg', nil)
    end
  end

  def test_create_with_blank_email
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/customers', body: fixtures['responses']['customer']['blank_email'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::Customer.create(email: nil)
    end
  end

  def test_create_success
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/customers', body: fixtures['responses']['customer']['created'])
    customer = PinPayment::Customer.create(email: 'foo@example.com')
    assert_equal 'cus__03Cn1lSk3offZ0IGkwpCg', customer.token
  end

  def test_direct_update
    FakeWeb.register_uri(:put, 'https://test-api.pin.net.au/1/customers/cus__03Cn1lSk3offZ0IGkwpCg', body: fixtures['responses']['customer']['updated'])
    customer = PinPayment::Customer.update('cus__03Cn1lSk3offZ0IGkwpCg', 'changed@example.com')
    assert_equal 'changed@example.com', customer.email
  end

  def test_object_update
    FakeWeb.register_uri(:get, 'https://test-api.pin.net.au/1/customers/cus__03Cn1lSk3offZ0IGkwpCg', body: fixtures['responses']['customer']['created'])
    customer = PinPayment::Customer.find('cus__03Cn1lSk3offZ0IGkwpCg')
    assert_equal 'foo@example.com', customer.email

    FakeWeb.register_uri(:put, 'https://test-api.pin.net.au/1/customers/cus__03Cn1lSk3offZ0IGkwpCg', body: fixtures['responses']['customer']['updated'])
    customer.update('changed@example.com')
    assert_equal 'changed@example.com', customer.email
  end

  def test_find_customer
    FakeWeb.register_uri(:get, 'https://test-api.pin.net.au/1/customers/cus__03Cn1lSk3offZ0IGkwpCg', body: fixtures['responses']['customer']['created'])
    customer = PinPayment::Customer.find('cus__03Cn1lSk3offZ0IGkwpCg')
    assert_equal 'foo@example.com', customer.email
  end

  def test_fetch_all_customers
    FakeWeb.register_uri(:get, 'https://test-api.pin.net.au/1/customers', body: fixtures['responses']['customer']['all'])
    customers = PinPayment::Customer.all
    assert_equal 2, customers.length
    assert_kind_of PinPayment::Customer, customers.first
    assert_equal 'user1@example.com', customers.first.email
  end
end
