# PinPayment

Ruby interface to the http://pin.net.au/ API.

## Installation

Using bundler you can add the gem to your Gemfile.

    gem 'pin_payment'

Or you can clone the repo and build them gem yourself:

    bundle install --path gems
    bundle exec rake build
    gem install pkg/pin*.gem

## Usage

First you will need to set your `public_key`, `secret_key`, and the `api_url`.
These can be found on your pin.net.au dashboard (under the "Account" section).
If you're using rails, this is best done in an initializer such as
`config/initializers/pin_payment.rb`, and you will need different keys for different
environments, e.g. wrap them around `if Rails.env.development?`.

```ruby
PinPayment.public_key = 'super nintendo chalmers'
PinPayment.secret_key = 'purple monkey dishwasher'
PinPayment.api_url    = 'http://api.pin.net.au' # Live endpoint, the default is the test endpoint
```

Creating the customer on pin.net.au is only required if you want to bill the
customer in future (e.g. recurring billing, where writing the background
task is up to you), if you are only doing a single transaction, this step is
not required (but recommended).

```ruby
customer = PinPayment::Customer.create('foo@example.com', params[:card_token])
```

The important information from the returned object is `customer.token`. You
will need this for future billing. Store it in your own application
somewhere.

Now you can create charges.

```ruby
charge = PinPayment::Charge.create(
  customer:    customer, # or you can pass customer.token, either way
  email:       customer.email,
  amount:      1000,
  currency:    'USD', # only AUD and USD are supported by pin.net.au
  description: 'Widgets',
  ip_address:  request.remote_ip
)

if charge.success?
  # You would now store charge.token as a reference for this payment
end
```

If you don't want to create customer records and just want to create once of
charges with the credit card data, this is quite simple also. You can do this
in 2 steps if you like, or 1.

First create the card

```ruby
card = PinPayment::Card.create(
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
)
```

Once you have created the card via the API, you will have a `PinPayment::Card`
object, and you can use the charge example code above and replace the customer
key in the has with `:card`. The same principle applies here, you can pass
`:card` into the charge creation as the card object, or as a simple string being
the card token.

Alternatively, you can skip the card creation step, and pass `:card` to the
charge creation as a hash itself, it will create the card for you as part of the
charge process. Example

```ruby
charge = PinPayment::Charge.create(
  email:       customer.email,
  amount:      1000,
  currency:    'USD', # only AUD and USD are supported by pin.net.au
  description: 'Widgets',
  ip_address:  request.ip,
  card:        {
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
)
```

You can refund charges as well, either directly on the charge object with
`charge.refund!` or you can pass a charge object or token directly into
`PinPayment::Refund.create`

Both the Charge and Customer objects have an `all` method that you can use to
iterate over your customers and charges. They simply return an array of their
respective objects.

They also both of course have a `find` method which takes a single argument,
being the token. For this reason I highly suggest storing `charge.token` as your
payment reference whenever you are creating payments. As well as storing
`customer.token` against your customers in your own customer database.

## TODO

   * The `all` methods need to deal with pagination.
   * Implement `PinPayment::Customer.charges`
   * Implement `PinPayment::Charge.search`
   * There is more info about a charge in a response than what the API says.
     E.g. there is info about the fees, refund status, and trasfer status. Need
     to find out what this data is all about. Since it's undocumented, I am
     hesitent to implement anything that relies on it as yet.

## Testing

I'm just using the `fakeweb` gem at the moment with a bunch of pre-defined
responses that I know the API gives. We're not really here to test the output of
the API, I think we can safely assume it will always give the same output for
the same input, and I don't really want to spam their service every time someone
runs the test suite. Nor do I want to hard code my test API keys or expect every
developer to create a pin account.

Having said that, you can simply jump into `test/test_helper.rb` and comment out
the line that sets up fakeweb, then you can uncomment the lines below that and
put your own pin.net.au test API keys into the code and run the tests. Note
however that this will create a large amount of customers and charges in your
test dashboard on pin.net.au.

Suggestions on improvement here are welcome though.

## Contributing

Fork it and send me pull requests. I'll happily merge it or tell you what I
think in no uncertain terms :-)

Do not bother sending me a pull request for ruby 1.8 support though. I will tell
you where to go, and it involves a bridge.

## Maintainer(s)

  * Danial Pearce (git@tigris.id.au)
