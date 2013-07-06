module PinPayment
  class Error < StandardError

    def self.create type, description, messages = nil
      klass = case type
        when 'token_already_used'; TokenAlreadyUsed
        when 'invalid_resource';   InvalidResource
        when 'resource_not_found'; ResourceNotFound
        else self
      end
      if messages.is_a?(Array)
        description = description + ' ' + messages.map{|x| "(#{x['message']})" }.join(' & ')
      elsif messages.is_a?(Hash)
        description = description + ' ' + messages.values.flatten.map{|x| "(#{x})" }.join(' & ')
      end
      klass.new(description)
    end

    class InvalidResponse  < Error; end
    class InvalidResource  < Error; end
    class ResourceNotFound < Error; end
    class TokenAlreadyUsed < Error; end

  end
end
