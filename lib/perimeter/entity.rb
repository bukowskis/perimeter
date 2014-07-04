module Perimeter
  module Entity
    extend ActiveSupport::Concern

    included do
      include Virtus.model
      include ActiveModel::Conversion
      include ActiveModel::Validations

      extend  ActiveModel::Naming

    end

  end
end
