require 'active_support/concern'
require 'trouble'
require 'perimeter/repository/error'

module Perimeter
  module Repository
    module Adapters
      module Abstract
        extend ActiveSupport::Concern

        module ClassMethods

          # Returns an Operation instance that MUST hold an Entity as object.
          # Success is defined as "the record could be found", everything else is a failure.
          # If the record does not exist, there is *no* Trouble. Any other StandardError notifies Trouble.
          #
          def find(id)
            raise NotImplementedError
          end

          # Returns an Operation instance that MUST hold an Entity as object.
          # Success is defined as "there was no record and now there is one", everything else is a failure.
          # Validations are run on the Record.
          #
          def create(attributes)
            raise NotImplementedError
          end

          # Returns an Operation instance that MAY hold an Entity as object.
          # Success is defined as "there was a record and now some/all attributes have been updated", everything else is a failure.
          # NOTE: Whether validations are run on the Record first is backend specific.
          #
          def update(id, attributes)
            raise NotImplementedError
          end

          # Returns an Operation instance that SHOULD hold the destroyed Entity as object.
          # Success is defined as "after this operation the record is or already was gone", everything else is a failure.
          #
          def destroy(id)
            raise NotImplementedError
          end

          # Returns an Entity or raises a FindingError.
          #
          def find!(id)
            operation = find id
            raise ::Perimeter::Repository::FindingError, operation.meta.exception if operation.failure?
            operation.object
          end

          # Returns an Entity or raises a CreationError.
          #
          def create!(id)
            operation = create id
            raise ::Perimeter::Repository::CreationError, operation.meta.exception if operation.failure?
            operation.object
          end

          # Returns true or raises a DestructionError.
          #
          def destory!(id)
            operation = destroy id
            raise ::Perimeter::Repository::DestructionError, operation.meta.exception if operation.failure?
            true
          end

        end

      end
    end
  end
end
