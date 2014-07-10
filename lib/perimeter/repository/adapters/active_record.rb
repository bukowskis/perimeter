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

          rescue Exception => exception
            ::Trouble.notify exception
            Operations.failure :backend_error, object: exception
          end

          def create(attributes)
            entity = attributes_to_entity attributes
            # Triggering validation hooks which may change the state of the Entity
            entity_invalid = entity.invalid?
            # Converting the (now possibly modified) Entity into a Record
            record = entity_to_record entity, strip_id: true
            # Triggering validation hooks on the Record to allow for state changes as well
            record_invalid = record.invalid?

            if entity_invalid or record_invalid
              # Merging errors from Record into Entity
              record.errors.each { |attribute, message| entity.errors.add attribute, message }
              return Operations.failure(:validation_failed, object: entity)
            end

            id = entity.id.presence || record.id.presence || attributes[:id].presence || attributes['id'].presence
            if id && backend.find_by_id(id)
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
