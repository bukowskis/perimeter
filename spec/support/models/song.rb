require 'perimeter/entity'

class Song
  include Perimeter::Entity

  attribute :title, String
end
