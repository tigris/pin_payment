require 'test_helper'

class TestPinCustomer < MiniTest::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
  end

  def test_update_with_blank_email
    FakeWeb.register_uri(:put, 'https://test-api.pin.net.au/1/customers/cus__03Cn1lSk3offZ0IGkwpCg', body: fixtures['responses']['customer']['blank_email'])
    assert_raises PinPayment::Error::InvalidResource do
      PinPayment::Customer.update(token: 'cus__03Cn1lSk3offZ0IGkwpCg', email: nil)
    end
  end

  def test_update_with_blank_token
    FakeWeb.register_uri(:put, 'https://test-api.pin.net.au/1/customers/', body: fixtures['responses']['customer']['blank_token'])
    assert_raises PinPayment::Error::ResourceNotFound do
      PinPayment::Customer.update(email: 'foo@example.com')
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
    assert_equal customer.token, 'cus__03Cn1lSk3offZ0IGkwpCg'
  end

  def test_direct_update
    FakeWeb.register_uri(:put, 'https://test-api.pin.net.au/1/customers/cus__03Cn1lSk3offZ0IGkwpCg', body: fixtures['responses']['customer']['updated'])
    customer = PinPayment::Customer.update(token: 'cus__03Cn1lSk3offZ0IGkwpCg', email: 'changed@example.com')
    assert_equal customer.email, 'changed@example.com'
  end

  def test_object_update
    FakeWeb.register_uri(:get, 'https://test-api.pin.net.au/1/customers/cus__03Cn1lSk3offZ0IGkwpCg', body: fixtures['responses']['customer']['created'])
    customer = PinPayment::Customer.find('cus__03Cn1lSk3offZ0IGkwpCg')

    FakeWeb.register_uri(:put, 'https://test-api.pin.net.au/1/customers/cus__03Cn1lSk3offZ0IGkwpCg', body: fixtures['responses']['customer']['updated'])
    customer.update(email: 'changed@example.com')
    assert_equal customer.email, 'changed@example.com'
  end

  def test_find_customer
    FakeWeb.register_uri(:get, 'https://test-api.pin.net.au/1/customers/cus__03Cn1lSk3offZ0IGkwpCg', body: fixtures['responses']['customer']['created'])
    customer = PinPayment::Customer.find('cus__03Cn1lSk3offZ0IGkwpCg')
    assert_equal customer.email, 'foo@example.com'
  end
end
