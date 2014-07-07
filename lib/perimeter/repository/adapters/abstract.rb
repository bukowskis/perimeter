module Perimeter
  module Repository
    module Adapters
      module Abstract

        FindingError     = Class.new(StandardError)
        DestructionError = Class.new(StandardError)

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods

          # Returns an Operation instance that MUST hold an Entity as object.
          # Success is defined as "the record could be found", everything else is a failure.
          #
          def find(id)
            raise NotImplementedError
          end

          # Returns an Operation instance that MAY hold an Entity as object.
          # Success is defined as "after this operation the record is or was already gone", everything else is a failure.
          #
          def destroy(id)
            raise NotImplementedError
          end

          # Returns an Entity or raises a FindingError.
          #
          def find!(id)
            operation = find id
            raise FindingError, operation.meta.exception if operation.failure?
            operation.object
          end

          # Returns true or raises a DestructionError.
          #
          def destory!(id)
            operation = destroy id
            raise DestructionError, operation.meta.exception if operation.failure?
            true
          end

        end

      end
    end
  end
end
