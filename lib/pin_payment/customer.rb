module PinPayment
  class Customer < Base
    ATTRIBUTES = [:token, :email, :created_at, :card_token]
    attr_accessor *ATTRIBUTES
    protected     *ATTRIBUTES.map{|x| "#{x}=" }

    def self.create options
      response = post(
        URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/customers' },
        options.select{|k| %w(email card_token).include?(k.to_s) }
      )
      new(response.delete('token'), response)
    end

    def self.update options
      new(options[:token] || options['token']).tap{|c| c.update options }
    end

    def update options
      response = self.class.put(
        URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/customers/#{token}" },
        options.select{|k| %w(email card_token).include?(k.to_s) }
      )
      %w(email card_token).each{|k| send("#{k}=", response[k]) }
      self
    end

    def self.find token
      response = get(URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/customers/#{token}" })
      new(response.delete('token'), response)
    end

    def self.all # TODO: pagination
      response = get(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/customers' })
      response.map{|x| new(x.delete('token'), x) }
    end

  end
end
