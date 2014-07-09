require 'perimeter/entity'

class Game
  include Perimeter::Entity

  attribute :name
  attribute :genre

  validates :name, presence: true
end
