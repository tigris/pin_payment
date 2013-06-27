require 'json'
require 'pin_payment/error'

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
      response.is_a?(Hash) ? parse_card_data(response) : response.map{|x| parse_card_data(x) }
    end

    def self.parse_card_data hash
      hash  = hash.dup
      card  = hash.delete('card') if hash['card']
      card  = hash.delete(:card)  if hash[:card]
      token = hash.delete('card_token') if hash['card_token']
      token = hash.delete(:card_token)  if hash[:card_token]
      if card.is_a?(Card)
        card.token = token if token and !card.token
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

    def self.parse_options_for_request attributes, options
      attributes = attributes.map(&:to_s)
      options    = parse_card_data(options.select{|k| attributes.include?(k.to_s) })
      card       = options.delete('card') if options['card']
      return options unless card and card.is_a?(Card)
      return options.merge(card_token: card.token) if card.token

      # Ruby's Net::HTTP#set_form_data doesn't deal with nested hashes :(
      card.to_hash.each{|k,v| options["card[#{k}]"] = v }
      options
    end

  end
end
