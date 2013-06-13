module Pin
  class Charge < Base
    attr_reader :token, :amount, :currency, :description, :email, :ip_address, :created_at, :card_token

    def self.create options
      response = self.post(
        URI.parse(Pin.api_url).tap{|uri| uri.path = '/1/charges' },
        options.select{|k| %w(amount currency description email ip_address card_token customer_token).include?(k.to_s) }
      )
      self.new.tap do |charge|
        charge.instance_variable_set('@card_token', response['card']['token']) if response['card']
        %w(token amount currency description email ip_address created_at error_message success).each do |key|
          charge.instance_variable_set("@#{key}", response[key])
        end
      end
    end

    def success?
      @success == true
    end

    def errors
      @error_message
    end
  end
end
