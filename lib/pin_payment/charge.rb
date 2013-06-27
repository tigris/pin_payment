module PinPayment
  class Charge < Base
    attr_accessor :token,  :amount,  :currency,  :description,  :email,  :ip_address,  :created_at,  :card,  :customer_token,  :success
    protected     :token=, :amount=, :currency=, :description=, :email=, :ip_address=, :created_at=, :card=, :customer_token=, :success=

    # Uses the pin API to create a charge.
    #
    # @param [Hash] charge_data
    # @option charge_data [String] :amount
    # @option charge_data [String] :currency
    # @option charge_data [String] :email
    # @option charge_data [String] :description
    # @option charge_data [String] :ip_address
    # @option charge_data [String] :customer_token
    # @option charge_data [String,<PinPayment::Card>,Hash] :card
    # @return [PinPayment::Charge]
    def self.create charge_data
      attributes = self.attributes - [:token, :success, :created_at] # fix attributes allowed by POST API
      options    = parse_options_for_request(attributes, charge_data)
      response   = post(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/charges' }, options)
      new(response.delete('token'), response)
    end

    # Fetches all of your charges using the pin API.
    #
    # @return [Array<PinPayment::Charge>]
    # TODO: pagination
    def self.all
      response = get(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/charges' })
      response.map{|x| new(x.delete('token'), x) }
    end

    # Refund a charge via the pin API.
    #
    # @return [PinPayment::Refund]
    def refund!
      Refund.create token
    end

    # @return [Boolean]
    def success?
      success == true
    end

    protected

    def self.attributes
      [:token, :amount, :currency, :description, :email, :ip_address, :created_at, :card, :customer_token, :success]
    end
  end
end
