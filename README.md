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
customer = PinPayment::Customer.create(email: 'foo@example.com', card_token: params[:card_token])
```

The important information from the returned object is `customer.token`. You
will need this for future billing. Store it in your own application
somewhere.

Now you can create charges.

```ruby
charge = PinPayment::Charge.create(
  customer_token: customer.token, # you can optionally pass a card_token instead
  email:          customer.email,
  amount:         1000,
  currency:       'USD',
  description:    'Widgets',
  ip_address:     request.ip
)

if charge.success?
  # You would now store charge.token as a reference for this payment
end
```

## TODO

  * `PinPayment::Card` is non existent. I haven't had a use for it myself as yet, it
    would be easy to build and will do so if I ever see the need. But as per the
    [guide in the documentation](https://pin.net.au/docs/guides/payment-forms),
    for a web interface it is much better to have the `card_token` created in
    the javascript and never have the responsibility of credit card info being
    sent directly to your server.
  * Neither of the models support being handed a `card` hash. The API supports
    doing so, but as above, I've not yet had the need and have always had a
    `card_token` handy to pass in.

## Testing

I'm just using the `fakeweb` gem at the moment with a bunch of pre-defined
responses that I know the API gives. We're not really here to test the output of
the API, I think we can safely assume it will always give the same output for
the same input, and I don't really want to spam their service every time someone
runs the test suite. Nor do I want to hard code my test API keys or expect every
developer to create a pin account. Suggestions on improvement here are welcome
though.

## Contributing

Fork it and send me pull requests. I'll happily merge it or tell you what I
think in no uncertain terms :-)

Do not bother sending me a pull request for ruby 1.8 support though. I will tell
you where to go, and it involves a bridge.

## Maintainer(s)

  * Danial Pearce (git@tigris.id.au)
