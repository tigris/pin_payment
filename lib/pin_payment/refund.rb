module PinPayment
  class Refund < Base
    attr_reader :token, :amount, :currency, :charge_token, :created_at

    def self.create options
      response = self.post(
        URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/charges/#{options[:charge_token] || options['charge_token']}/refunds" },
        {}
      )
      self.new.tap do |charge|
        %w(token amount currency created_at error_message status_message).each do |key|
          charge.instance_variable_set("@#{key}", response[key])
        end
      end
    end

    # TODO: API documentation only shows success as being "null" in the JSON
    # response, so not sure this is possible. All my refunds on the test site
    # end up in a "Pending" state so not entirely sure on this one.
    def success?
      @success == true
    end

    def status
      @status_message
    end

    def errors
      @error_message
    end
  end
end
