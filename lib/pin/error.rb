module Pin
  class Error < Exception

    def self.create type, description, messages = nil
      klass = case type
        when 'token_already_used'; TokenAlreadyUsed
        when 'invalid_resource';   InvalidResource
        when 'resource_not_found'; ResourceNotFound
        else self
      end
      description = description + ' ' + messages.map{|x| "(#{x['message']})" }.join(' & ') if messages
      klass.new(description)
    end

    class InvalidResponse  < Error; end
    class InvalidResource  < Error; end
    class ResourceNotFound < Error; end
    class TokenAlreadyUsed < Error; end

  end
end
