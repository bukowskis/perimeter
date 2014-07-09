require 'operation'
require 'perimeter/repository'
require 'perimeter/repository/adapters/abstract'
require 'active_support/concern'

module Perimeter
  module Repository
    module Adapters
      module ActiveRecord
        extend ActiveSupport::Concern

        include Perimeter::Repository
        include Perimeter::Repository::Adapters::Abstract

        module ClassMethods

          def find(id)
            record = backend.find id
            entity = record_to_entity record
            Operations.success :record_found, object: entity

          rescue ::ActiveRecord::RecordNotFound => exception
            Operations.failure :record_not_found, object: exception

          rescue StandardError => exception
            ::Trouble.notify exception
            Operations.failure :backend_error, object: exception
          end

          def create(attributes)
            entity = entity_class.new attributes
            # Triggering validation hooks which may change the state of the Entity
            entity_is_valid = entity.valid?
            # Transferring the Entity into a Record
            record = backend.new entity.attributes
            # Triggering validation hooks on the Backend
            record_is_valid = record.valid?

            unless entity_is_valid && record_is_valid
              # Merging errors from both Entity and Record
              record.errors.each do |attribute, message|
                entity.errors.add attribute, message
              end
              return Operations.failure(:validation_failed, object: entity)
            end

            id = attributes[:id] || attributes['id'] || entity.id || record.id
            if find(id).success?
              return Operations.failure :record_already_exists
            end

            if record.save
              Operations.success :record_created, object: record_to_entity(record)
            else
              Operations.failure :creation_failed, object: entity
            end
          end

          def destroy(id)
            unless record = backend.find_by_id(id)
              return Operations.success(:nothing_to_destroy)
            end

            if record.destroy
              Operations.success :record_destroyed, object: record_to_entity(record)
            else
              Operations.failure :destruction_failed
            end
          end

        end

      end
    end
  end
end
