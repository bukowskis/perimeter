require 'perimeter/entity'

module Games
  class Backend
    include Virtus.model
    extend  ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attribute :id
    attribute :name
    attribute :genre

    validates :genre, presence: true

  end
end
