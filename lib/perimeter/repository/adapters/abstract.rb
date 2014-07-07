module Perimeter
  module Repository
    module Adapters
      module Abstract

        FindingError = Class.new(StandardError)

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods

          def find(id)
            raise NotImplementedError
          end

          # Returns an Entity or raises a FindingError.
          #
          def find!(id)
            operation = find id
            raise FindingError, operation.meta.exception if operation.failure?
            operation.object
          end

        end

      end
    end
  end
end
