require 'virtus'

module Perimeter
  module Entity

    def self.included(base)
      base.class_eval do
        include Virtus.model
      end
    end


    #included do
    #  include Virtus.model
    #
    #  include ActiveModel::Conversion
    #  include ActiveModel::Validations
    #  extend  ActiveModel::Naming
    #end

  end
end
