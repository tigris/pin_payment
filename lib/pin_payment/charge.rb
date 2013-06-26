module PinPayment
  class Charge < Base
    ATTRIBUTES = [:token, :amount, :currency, :description, :email, :ip_address, :created_at, :card, :customer_token, :success].freeze
    attr_accessor *ATTRIBUTES
    protected     *ATTRIBUTES.map{|x| "#{x}=" }

    def self.create options
      attributes = ATTRIBUTES - [:token, :success, :created_at] # fix attributes allowed by POST API
      options    = parse_options_for_request(attributes, options)
      response   = post(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/charges' }, options)
      new(response.delete('token'), response)
    end

    def refund!
      Refund.create token
    end

    def success?
      success == true
    end
  end
end
