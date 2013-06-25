require 'json'
require 'pin_payment/error'

module PinPayment
  class Base

    protected

    def self.post uri, options
      fetch Net::HTTP::Post, uri, options
    end

    def self.put uri, options
      fetch Net::HTTP::Put, uri, options
    end

    def self.get uri, options
      fetch Net::HTTP::Get, uri, options
    end

    # TODO: Accept card as a hash that would create the card at the same time as the charge
    def self.fetch klass, uri, options
      client             = Net::HTTP.new(uri.host, uri.port)
      client.use_ssl     = true
      client.verify_mode = OpenSSL::SSL::VERIFY_PEER
      response           = client.request(
        klass.new(uri.request_uri).tap do |http|
          http.basic_auth(PinPayment.secret_key, '')
          http['User-Agent'] = "#{self}/#{PinPayment::Version::STRING}"
          http.set_form_data options
        end
      )
      begin
        response = JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise Error::InvalidResponse.new(e.message)
      end
      raise(Error.create(response['error'], response['error_description'], response['messages'])) if response['error']
      response['response']
    end

  end
end
