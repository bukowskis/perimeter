require 'perimeter/entity'

class City
  include Perimeter::Entity

  attribute :name, String
end
