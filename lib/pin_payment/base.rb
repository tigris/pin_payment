require 'json'
require 'pin_payment/error'
require 'net/http'

module PinPayment
  class Base

    def initialize token, options = {}
      self.token = token
      self.class.parse_card_data(options).each{|k,v| send("#{k}=", v) if self.class.attributes.include?(k.to_sym) }
    end

    protected

    def self.post uri, options = {}
      fetch Net::HTTP::Post, uri, options
    end

    def self.put uri, options = {}
      fetch Net::HTTP::Put, uri, options
    end

    def self.get uri, options = {}
      fetch Net::HTTP::Get, uri, options
    end

    def self.fetch klass, uri, options
      client             = Net::HTTP.new(uri.host, uri.port)
      client.use_ssl     = true
      client.verify_mode = OpenSSL::SSL::VERIFY_PEER
      response           = client.request(
        klass.new(uri.request_uri).tap do |http|
          http.basic_auth(PinPayment.secret_key, '')
          http['User-Agent'] = "#{self}/#{PinPayment::Version::STRING}"
          http.set_form_data options
        end
      )
      begin
        response = JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise Error::InvalidResponse.new(e.message)
      end
      raise(Error.create(response['error'], response['error_description'], response['messages'])) if response['error']
      response = response['response']
      response.is_a?(Hash) ? parse_object_tokens(response) : response.map{|x| parse_object_tokens(x) }
    end

    def self.parse_card_data hash
      hash  = hash.dup
      card  = hash.delete('card') if hash['card']
      card  = hash.delete(:card)  if hash[:card]
      token = hash.delete('card_token') if hash['card_token']
      token = hash.delete(:card_token)  if hash[:card_token]
      if card.is_a?(Card) && token && !card.token
        card.token = token
      elsif card.is_a?(Hash)
        card = Card.new(token || card[:token] || card['token'], card)
      elsif card.is_a?(String)
        card = Card.new(card)
      elsif token
        card = Card.new(token)
      end
      hash['card'] = card if card
      hash
    end

    def self.parse_customer_data hash
      hash     = hash.dup
      customer = hash.delete('customer') if hash['customer']
      customer = hash.delete(:customer)  if hash[:customer]
      token    = hash.delete('customer_token') if hash['customer_token']
      token    = hash.delete(:customer_token)  if hash[:customer_token]
      if customer.is_a?(Customer) and token and !customer.token
        customer.token = token
      elsif customer.is_a?(String)
        customer = Customer.new(customer)
      elsif token
        customer = Customer.new(token)
      end
      hash['customer'] = customer if customer
      hash
    end

    def self.parse_charge_data hash
      hash   = hash.dup
      charge = hash.delete('charge') if hash['charge']
      charge = hash.delete(:charge)  if hash[:charge]
      token  = hash.delete('charge_token') if hash['charge_token']
      token  = hash.delete(:charge_token)  if hash[:charge_token]
      if charge.is_a?(Charge) and token and !charge.token
        charge.token = token
      elsif charge.is_a?(String)
        charge = Charge.new(charge)
      elsif token
        charge = Charge.new(token)
      end
      hash['charge'] = charge if charge
      hash
    end

    def self.parse_bank_account_data hash
      hash      = hash.dup
      account   = hash.delete('bank_account')  if hash['bank_account']
      account   = hash.delete(:bank_account)   if hash[:bank_account]
      token     = hash.delete('bank_account_token')  if hash['bank_account_token']
      token     = hash.delete(:bank_account_token)   if hash[:bank_account_token]
      if account.is_a?(BankAccount) and token and !account.token
        account.token = token
      elsif account.is_a?(String)
        account = BankAccount.new(account)
      elsif account.is_a?(Hash)
        account = BankAccount.new(nil,account)
      elsif token
        account = BankAccount.new(token)
      end
      hash['bank_account'] = account if account
      hash
    end

    def self.parse_object_tokens hash
      parse_charge_data(parse_customer_data(parse_card_data(parse_bank_account_data(hash))))
    end

    def self.parse_options_for_request attributes, options
      attributes = attributes.map(&:to_s)
      options    = parse_object_tokens(options.select{|k| attributes.include?(k.to_s) })

      if card = options.delete('card')
        if card.token
          options['card_token'] = card.token
        else
          # Ruby's Net::HTTP#set_form_data doesn't deal with nested hashes :(
          card.to_hash.each{|k,v| options["card[#{k}]"] = v }
        end
      end

      if bank_account = options.delete('bank_account')
        if bank_account.token
          options['bank_account_token'] = bank_account.token
        else
          # Ruby's Net::HTTP#set_form_data doesn't deal with nested hashes :(
          bank_account.to_hash.each{|k,v| options["bank_account[#{k}]"] = v }
        end
      end

      options['customer_token'] = options.delete('customer').token if options['customer']
      options['charge_token']   = options.delete('charge').token   if options['charge']

      options
    end

  end
end
