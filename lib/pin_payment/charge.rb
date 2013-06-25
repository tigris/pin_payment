module PinPayment
  class Charge < Base
    ATTRIBUTES = [:token, :amount, :currency, :description, :email, :ip_address, :created_at, :card_token, :customer_token, :success]
    attr_accessor *ATTRIBUTES
    protected     *ATTRIBUTES.map{|x| "#{x}=" }

    def self.create options
      options = options.reject{|x| x == 'token' } # field not allowed during create
      response = post(
        URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/charges' },
        options.select{|k| ATTRIBUTES.include?(k.to_s) }
      )
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
