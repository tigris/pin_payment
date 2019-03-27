module PinPayment
  class Refund < Base
    attr_accessor :token,  :amount,  :currency,  :charge,  :created_at,  :status_message
    protected     :token=, :amount=, :currency=, :charge=, :created_at=, :status_message=, :status_message

    # Uses the pin API to create a refund.
    #
    # @param [String, PinPayment::Charge] charge_or_token the charge (or token of the charge) to refund
    # @return [PinPayment::Refund]
    def self.create refund_data
      charge_or_token = refund_data.is_a?(Hash) ? refund_data[:charge] : refund_data
      token = charge_or_token.is_a?(Charge) ? charge_or_token.token : charge_or_token
      options = refund_data.is_a?(Hash) && refund_data[:amount] ? { amount: refund_data[:amount] } : {}
      response = post(URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/charges/#{token}/refunds" }, options)
      new(response.delete('token'), response)
    end

    # Fetches a refund using the Pin API.
    #
    # @param [String] token the charge token
    # @return [PinPayment::Refund]
    def self.find token
      response = get(URI.parse(PinPayment.api_url).tap{ |uri| uri.path = "/1/refunds/#{token}" })
      new(response.delete('token'), response)
    end

    # @return [Boolean]
    # TODO: API documentation only shows success as being "null" in the JSON
    # response, so not sure this is possible. All my refunds on the test site
    # end up in a "Pending" state so not entirely sure on this one.
    def success?
      @success == true
    end

    # @return [String]
    def status
      status_message
    end

    protected

    def self.attributes
      [:token, :amount, :currency, :charge, :created_at, :status_message]
    end
  end
end
