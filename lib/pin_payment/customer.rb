module PinPayment
  class Customer < Base
    attr_accessor :token,  :email,  :created_at,  :card
    protected     :token=, :email=, :created_at=, :card=

    # Uses the pin API to create a customer.
    #
    # @param [String] email the customer's email address
    # @param [String, PinPayment::Card, Hash] card_or_token the customer's credit card details
    # @return [PinPayment::Customer]
    def self.create email, card_or_token = nil
      attributes = self.attributes - [:token, :created_at]
      options    = parse_options_for_request(attributes, email: email, card: card_or_token)
      response   = post(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/customers' }, options)
      new(response.delete('token'), response)
    end

    # Update a customer using the pin API.
    #
    # @param [String] token the customer token
    # @param [String] email the customer's new email address
    # @param [String, PinPayment::Card, Hash] card_or_token the customer's new credit card details
    # @return [PinPayment::Customer]
    def self.update token, email, card_or_token = nil
      new(token).tap{|c| c.update(email, card_or_token) }
    end

    # Fetches a customer using the pin API.
    #
    # @param [String] token the customer token
    # @return [PinPayment::Customer]
    def self.find token
      response = get(URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/customers/#{token}" })
      new(response.delete('token'), response)
    end

    # Fetches all of your customers using the pin API.
    #
    # @return [Array<PinPayment::Customer>]
    # TODO: pagination
    def self.all
      response = get(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/customers' })
      response.map{|x| new(x.delete('token'), x) }
    end

    # Update a customer using the pin API.
    #
    # @param [String] email the customer's new email address
    # @param [String, PinPayment::Card, Hash] card_or_token the customer's new credit card details
    # @return [PinPayment::Customer]
    def update email, card_or_token = nil
      attributes = self.class.attributes - [:token, :created_at]
      options    = self.class.parse_options_for_request(attributes, email: email, card: card_or_token)
      response   = self.class.put(URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/customers/#{token}" }, options)
      self.email = response['email']
      self.card  = response['card']
      self
    end

    protected

    def self.attributes
      [:token, :email, :created_at, :card]
    end

  end
end
