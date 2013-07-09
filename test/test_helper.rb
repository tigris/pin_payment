require 'fakeweb'
require 'minitest/autorun'
require 'pin_payment'
require 'yaml'

def fixtures
  return @fixtures if @fixtures
  @fixtures = {}.tap do |f|
    f['responses'] = YAML.load(File.read File.join(File.dirname(__FILE__), 'fixtures', 'responses.yml'))
  end
end

def common_setup
  FakeWeb.allow_net_connect = false

  # If you want to test for realsies, change the above to true, and uncomment
  # below, after putting in your own test keys

  #PinPayment.secret_key = 'super secret'
  #PinPayment.public_key = 'not so secret'
end

def card_hash
  {
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

def charge_hash
  {
    amount:      400,
    currency:    'AUD',
    description: 'test charge',
    email:       'roland@pin.net.au',
    ip_address:  '203.192.1.172',
    card:        card_hash
  }
end

def created_customer
  FakeWeb.register_uri(:post, 'https://test-api.pin.net.au/1/customers', body: fixtures['responses']['customer']['created'])
  customer = PinPayment::Customer.create('foo@example.com', card_hash)
end

def created_charge
  FakeWeb.register_uri(:post, "https://test-api.pin.net.au/1/charges", body: fixtures['responses']['charge']['success'])
  charge = PinPayment::Charge.create(charge_hash)
end
