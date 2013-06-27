module PinPayment
  class Refund < Base
    attr_accessor :token,  :amount,  :currency,  :charge,  :created_at,  :status_message
    protected     :token=, :amount=, :currency=, :charge=, :created_at=, :status_message=, :status_message

    # Uses the pin API to create a refund.
    #
    # @param [String, PinPayment::Charge] charge_or_token the charge (or token of the charge) to refund
    # @return [PinPayment::Refund]
    def self.create charge_or_token
      token = charge_or_token.is_a?(Charge) ? charge_or_token.token : charge_or_token
      response = post(URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/charges/#{token}/refunds" })
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
