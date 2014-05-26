module PinPayment
  class Charge < Base
    attr_accessor :token,  :amount,  :currency,  :description,  :email,  :ip_address,  :created_at,  :card,  :customer,  :success,  :total_fees
    protected     :token=, :amount=, :currency=, :description=, :email=, :ip_address=, :created_at=, :card=, :customer=, :success=, :total_fees=

    # Uses the pin API to create a charge.
    #
    # @param [Hash] charge_data
    # @option charge_data [String] :amount *required*
    # @option charge_data [String] :currency *required* only AUD and USD supported
    # @option charge_data [String] :email *required*
    # @option charge_data [String] :description *required*
    # @option charge_data [String] :ip_address *required*
    # @option charge_data [String, PinPayment::Customer] :customer can be a customer token or a customer object
    # @option charge_data [String, PinPayment::Card, Hash] :card can be a card token, hash or a card object
    # @return [PinPayment::Charge]
    def self.create charge_data
      attributes = self.attributes - [:token, :success, :created_at] # fix attributes allowed by POST API
      options    = parse_options_for_request(attributes, charge_data)
      response   = post(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/charges' }, options)
      new(response.delete('token'), response)
    end

    # Fetches a charge using the Pin API.
    #
    # @param [String] token the charge token
    # @return [PinPayment::Charge]
    def self.find token
      response = get(URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/charges/#{token}" })
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
      Refund.create self
    end

    # @return [Boolean]
    def success?
      success == true
    end

    protected

    def self.attributes
      [:token, :amount, :currency, :description, :email, :ip_address, :created_at, :card, :customer, :success, :total_fees]
    end
  end
end
