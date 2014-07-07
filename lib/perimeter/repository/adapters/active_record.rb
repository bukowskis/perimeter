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

          def destroy(id)
            record = backend.find_by_id id
            if record
              entity = record_to_entity record
              if record.destroy
                Operations.success :record_destroyed, object: entity
              else
                Operations.failure :destruction_failed
              end
            else
              Operations.success :nothing_to_destroy
            end
          end

        end

      end
    end
  end
end
