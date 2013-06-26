module PinPayment
  class Card < Base
    ATTRIBUTES = [:token, :display_number, :scheme, :address_line1, :address_line2, :address_city, :address_postcode, :address_state, :address_country, :number, :expiry_month, :expiry_year, :cvc, :name].freeze
    attr_accessor *ATTRIBUTES
    protected     *ATTRIBUTES.map{|x| "#{x}=" }

    def self.create options
      attributes = ATTRIBUTES - [:token, :display_number, :scheme] # fix attributes allowed by POST API
      options    = parse_options_for_request(attributes, options)
      response   = post(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/cards' }, options)
      new(response.delete('token'), response)
    end

    def to_hash
      {}.tap{|h| ATTRIBUTES.each{|k| v = send(k) && h[k] = v }}
    end

  end
end
