require 'operations'
require 'perimeter/repository'
require 'perimeter/repository/adapters/abstract'

module Perimeter
  module Repository
    module Adapters
      module ActiveRecord

        def self.included(base)
          base.class_eval do
            include Perimeter::Repository
            include Perimeter::Repository::Adapters::Abstract
          end

          base.extend ClassMethods
        end

        module ClassMethods

          # Returns an Operation instance holding an Entity as object.
          # Success is defined as "the record could be found", everything else is a failure.
          #
          def find(id)
            record = backend.find id
            entity = record_to_entity record
            Operations.success :record_found, object: entity

          rescue ::ActiveRecord::RecordNotFound => exception
            Operations.failure :not_found, exception: exception

          rescue StandardError => exception
            Trouble.notify exception
            Operations.failure :backend_error, exception: exception
          end

        end

      end
    end
  end
end
