module PinPayment
  class Card < Base
    attr_accessor :token,  :display_number,  :scheme,  :address_line1,  :address_line2,  :address_city,  :address_postcode,  :address_state,  :address_country
    protected     :token=, :display_number=, :scheme=, :address_line1=, :address_line2=, :address_city=, :address_postcode=, :address_state=, :address_country=

    attr_accessor :number,  :expiry_month,  :expiry_year,  :cvc,  :name
    protected     :number,  :expiry_month,  :expiry_year,  :cvc,  :name
    protected     :number=, :expiry_month=, :expiry_year=, :cvc=, :name=

    # Use the pin API to create a credit card token, usable for 1 month from creation.
    #
    # @param [Hash] card_data
    # @option card_data [#to_s] :name
    # @option card_data [#to_s] :number
    # @option card_data [#to_s] :cvc
    # @option card_data [#to_s] :address_line1
    # @option card_data [#to_s] :address_line2 (optional)
    # @option card_data [#to_s] :address_city
    # @option card_data [#to_s] :address_postcode
    # @option card_data [#to_s] :address_country
    # @option card_data [#to_s] :expiry_month
    # @option card_data [#to_s] :expiry_year (4 digits required)
    # @return [PinPayment::Card]
    def self.create card_data
      attributes = self.attributes - [:token, :display_number, :scheme] # fix attributes allowed by POST API
      options    = parse_options_for_request(attributes, card_data)
      response   = post(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/cards' }, options)
      new(response.delete('token'), response)
    end

    # @return [Hash]
    def to_hash
      {}.tap{|h| self.class.attributes.each{|k| v = send(k) ; h[k] = v if v }}
    end

    protected

    def self.attributes
      [:token, :display_number, :scheme, :address_line1, :address_line2, :address_city, :address_postcode, :address_state, :address_country, :number, :expiry_month, :expiry_year, :cvc, :name]
    end

  end
end
