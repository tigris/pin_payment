module PinPayment
  class Customer < Base
    ATTRIBUTES = [:token, :email, :created_at, :card].freeze
    attr_accessor *ATTRIBUTES
    protected     *ATTRIBUTES.map{|x| "#{x}=" }

    def self.create email, card_or_token = nil
      attributes = ATTRIBUTES - [:token, :created_at]
      options    = parse_options_for_request(attributes, email: email, card: card_or_token)
      response   = post(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/customers' }, options)
      new(response.delete('token'), response)
    end

    def self.update token, email, card_or_token = nil
      new(token).tap{|c| c.update(email, card_or_token) }
    end

    def update email, card_or_token = nil
      attributes = ATTRIBUTES - [:token, :created_at]
      options    = self.class.parse_options_for_request(attributes, email: email, card: card_or_token)
      response = self.class.put(URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/customers/#{token}" }, options)
      self.email = response['email']
      self.card  = Card.new(response['card'])
      self
    end

    def self.find token
      response = get(URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/customers/#{token}" })
      new(response.delete('token'), response)
    end

    def self.all # TODO: pagination
      response = get(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/customers' })
      response.map{|x| new(x.delete('token'), x) }
    end

  end
end
