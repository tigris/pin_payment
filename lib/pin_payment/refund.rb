module PinPayment
  class Refund < Base
    ATTRIBUTES = [:token, :amount, :currency, :charge_token, :created_at, :status_message].freeze
    attr_accessor *ATTRIBUTES
    protected     *ATTRIBUTES.map{|x| "#{x}".to_sym }

    def self.create token
      response = post(URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/charges/#{token}/refunds" })
      new(response.delete('token'), response)
    end

    # TODO: API documentation only shows success as being "null" in the JSON
    # response, so not sure this is possible. All my refunds on the test site
    # end up in a "Pending" state so not entirely sure on this one.
    def success?
      @success == true
    end

    def status
      status_message
    end
  end
end
