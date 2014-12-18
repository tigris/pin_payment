module PinPayment
  class Balance < Base

    attr_accessor :available,  :pending
    protected     :available=, :pending=

    def initialize options = {}
      self.available = options["available"][0]
      self.pending = options["pending"][0]
    end

    # Uses the pin API to fetch your accounts balance.
    #
    # @return [PinPayment::Balance]
    def self.current_balance
      response = get(URI.parse(PinPayment.api_url).tap{|uri| uri.path = '/1/balance' }, {})
      new(response)
    end

  private

    def self.attributes
      [:available, :pending]
    end


  end
end
