module PinPayment
  class Customer < Base
    attr_reader :token, :email, :created_at, :card_token

    def self.create options
      response = post(
        URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/customers' },
        options.select{|k| %w(email card_token).include?(k.to_s) }
      )
      new.tap do |customer|
        customer.instance_variable_set('@card_token', response['card']['token']) if response['card']
        %w(token email created_at).each do |key|
          customer.instance_variable_set("@#{key}", response[key])
        end
      end
    end

    def self.update options
      customer = new.tap{|c| c.instance_variable_set('@token', options[:token] || options['token']) }
      customer.update options
    end

    def update options
      response = self.class.put(
        URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/customers/#{token}" },
        options.select{|k| %w(email card_token).include?(k.to_s) }
      )
      instance_variable_set('@card_token', response['card']['token']) if response['card']
      %w(token email created_at).each do |key|
        instance_variable_set("@#{key}", response[key])
      end
      self
    end

    def self.find token
      response = get(
        URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/customers/#{token}" },
        {}
      )
      new.tap do |customer|
        customer.instance_variable_set('@card_token', response['card']['token']) if response['card']
        %w(token email created_at).each do |key|
          customer.instance_variable_set("@#{key}", response[key])
        end
      end
    end

  end
end
