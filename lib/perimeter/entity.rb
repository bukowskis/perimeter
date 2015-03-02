# ActiveModel is not defined as gem dependency but we still depend on it (for now).
# With this technique we can use Perimeter in Rails 2 applications by backporting activemodel manually into the vendor directory.
require 'active_model'

require 'active_support/core_ext/module'
require 'active_support/concern'
require 'virtus'

module Perimeter
  module Entity
    extend ActiveSupport::Concern

    included do
      include Virtus.model

      extend  ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::Validations
      include ActiveModel::Validations::Callbacks

      attribute :id
      attr_accessor :errors
    end


    def to_param
      return if id.blank?
      id.to_s
    end

    def persisted?  # Rails 3+
      id.present?
    end

    def new_record?  # Rails 2
      !persisted?
    end

  end
end
