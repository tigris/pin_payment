require 'pin_payment/base'
require 'pin_payment/balance'
require 'pin_payment/bank_account'
require 'pin_payment/card'
require 'pin_payment/charge'
require 'pin_payment/customer'
require 'pin_payment/error'
require 'pin_payment/refund'
require 'pin_payment/recipient'
require 'pin_payment/transfer'
require 'pin_payment/version'

module PinPayment
  @@api_url    = 'https://test-api.pin.net.au'
  @@secret_key = nil
  @@public_key = nil

  def self.api_url
    @@api_url
  end

  def self.api_url=(url)
    @@api_url = url
  end

  def self.secret_key
    @@secret_key
  end

  def self.secret_key=(key)
    @@secret_key = key
  end

  def self.public_key
    @@public_key
  end

  def self.public_key=(key)
    @@public_key = key
  end
end
