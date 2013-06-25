# TODO: Convert to a gem

require 'pin/base'
require 'pin/charge'
require 'pin/customer'
require 'pin/error'
require 'pin/refund'
require 'pin/version'

module Pin
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
