require 'fakeweb'
require 'minitest/autorun'
require 'pin_payment'
require 'yaml'

def fixtures
  return @fixtures if @fixtures
  @fixtures = {}.tap do |f|
    f['responses'] = YAML.load(File.read File.join(File.dirname(__FILE__), 'fixtures', 'responses.yml'))
  end
end
