module PinPayment
  class Recipient < Base
    attr_accessor :token, :email, :name, :bank_account, :bank_account_token
    protected :token=, :email=, :name=, :bank_account=, :bank_account_token=


    # Uses the pin API to create a recipient.
    #
    # @param [Hash] recipient_data
    # @option recipient_data [String] :email *required*
    # @option recipient_data [String] :name *required*
    # @option recipient_data [String,PinPayment::BankAccount,Hash] :bank_account can be a token, hash or bank account object
    # @return [PinPayment::Recipient]
    def self.create recipient_data
      attributes = self.attributes - [:token] # fix attributes allowed by POST API
      options    = parse_options_for_request(attributes, recipient_data)
      response   = post(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/recipients' }, options)
      new(response.delete('token'), response)
    end

    # Update a recipient using the pin API.
    #
    # @param [String] token *required*
    # @param [String] email *required*
    # @param [String,PinPayment::BankAccount,Hash] bank_account can be a token, hash or bank account object *required*
    # @return [PinPayment::Recipient]
    def self.update token, email, card_or_token = nil
      new(token).tap{|c| c.update(email, card_or_token) }
    end

    # Fetches all of your recipients using the pin API.
    #
    # @return [Array<PinPayment::Recipient>]
    # TODO: pagination
    def self.all
      response = get(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/recipients' })
      response.map{|x| new(x.delete('token'), x) }
    end

    # Fetches a customer using the pin API.
    #
    # @param [String] token the recipient token
    # @return [PinPayment::Recipient]
    def self.find token
      response = get(URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/recipients/#{token}" })
      new(response.delete('token'), response)
    end

    # Update a recipient using the pin API.
    #
    # @param [String] email the recipients's new email address
    # @param [String, PinPayment::BankAccount, Hash] account_or_token the recipient's new bank account details
    # @return [PinPayment::Customer]
    def update email, account_or_token = nil
      attributes = self.class.attributes - [:token, :created_at]
      options    = self.class.parse_options_for_request(attributes, email: email, bank_account: account_or_token)
      response   = self.class.put(URI.parse(PinPayment.api_url).tap{|uri| uri.path = "/1/recipients/#{token}" }, options)
      self.email = response['email']
      self.bank_account  = response['bank_account']
      self
    end


    private

    def self.attributes
      [:token,:email,:name,:bank_account]
    end

  end
end
