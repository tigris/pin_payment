module PinPayment
  class BankAccount < Base

    attr_accessor :token,  :name,  :bsb,  :number, :bank_name
    protected     :token=, :name=, :bsb=, :number=, :bank_name=

    # Uses the pin API to create a bank account.
    #
    # @param [Hash] bank_account_data
    # @option bank_account_data [String] :name *required*
    # @option bank_account_data [String] :bsb *required*
    # @option bank_account_data [String] :number *required*
    # @return [PinPayment::BankAccount]
    def self.create bank_account_data
      attributes = self.attributes - [:token,:bank_name] # fix attributes allowed by POST API
      options    = parse_options_for_request(attributes, bank_account_data)
      response   = post(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/bank_accounts' }, options)
      new(response.delete('token'), response)
    end

    # @return [Hash]
    def to_hash
      {}.tap do |hash|
        self.class.attributes {|attribute| value = send(attribute); hash[attribute] = value if value}
      end
    end

  protected

    def self.attributes
      [:token, :name, :bsb, :number, :bank_name]
    end

  end
end
