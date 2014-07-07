require 'virtus'

module Perimeter
  module Entity

    def self.included(base)
      base.class_eval do
        include Virtus.model
      end
    end

    def to_param
      return if id.blank?
      id.to_s
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
