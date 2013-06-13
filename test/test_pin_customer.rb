require 'test_helper'

class TestPinCustomer < MiniTest::Unit::TestCase
  def setup
    FakeWeb.allow_net_connect = false
  end

  def test_update_with_blank_email
    FakeWeb.register_uri(:put, 'https://test-api.pin.net.au/1/customers/cus__03Cn1lSk3offZ0IGkwpCg', body: fixtures['responses']['update_customer']['blank_email'])
    assert_raises Pin::Error::InvalidResource do
      Pin::Customer.update(token: 'cus__03Cn1lSk3offZ0IGkwpCg', email: nil)
    end
  end

  def test_update_with_blank_token
    FakeWeb.register_uri(:put, 'https://test-api.pin.net.au/1/customers/', body: fixtures['responses']['update_customer']['blank_token'])
    assert_raises Pin::Error::ResourceNotFound do
      Pin::Customer.update(email: 'foo@example.com')
    end
  end

  def test_create_with_blank_email
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/customers', body: fixtures['responses']['create_customer']['blank_email'])
    assert_raises Pin::Error::InvalidResource do
      Pin::Customer.create(email: nil)
    end
  end

  def test_create_success
    FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/customers', body: fixtures['responses']['create_customer']['success'])
    customer = Pin::Customer.create(email: 'foo@example.com')
    assert_equal customer.token, 'cus__03Cn1lSk3offZ0IGkwpCg'
  end

  def test_update_success
    FakeWeb.register_uri(:put, 'https://test-api.pin.net.au/1/customers/cus__03Cn1lSk3offZ0IGkwpCg', body: fixtures['responses']['update_customer']['success'])
    customer = Pin::Customer.update(token: 'cus__03Cn1lSk3offZ0IGkwpCg', email: 'foo@example.com')
    assert_equal customer.token, 'cus__03Cn1lSk3offZ0IGkwpCg'
  end
end
