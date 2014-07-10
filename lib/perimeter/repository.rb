require 'hooks'
require 'active_support/concern'
require 'active_support/core_ext'

module Perimeter
  module Repository
    extend ActiveSupport::Concern

    OperationError = Class.new StandardError

    included do
      include ::Hooks
      define_hook :after_conversion
    end

    module ClassMethods

      # ––––––––––––––––––––––
      # Class name definitions
      # ––––––––––––––––––––––

      def backend_class(*args)
        @backend_class = args.first unless args.empty?
        @backend_class || default_backend_class
      end

      def entity_class(*args)
        @entity_class = args.first unless args.empty?
        @entity_class || default_entity_class
      end

      # Convenience Wrapper
      def backend
        backend_class
      end

      private

      # –––––––––––––––––––
      # Default Class names
      # –––––––––––––––––––

      def default_backend_class
        backend_class_name = name + '::Backend'
        backend_class_name.constantize

      rescue NameError => exception
        if exception.message.to_s == "uninitialized constant #{backend_class_name}"
          raise NameError, %{Repository "#{name}" expects the Backend "#{backend_class_name}" to be defined.}
        else
          raise exception
        end
      end

      def default_entity_class
        entity_class_name = name.singularize
        entity_class_name.constantize

      rescue NameError => exception
        if exception.message.to_s == "uninitialized constant #{entity_class_name}"
          raise NameError, %{Repository "#{name}" expects the Entity "#{entity_class_name}" to be defined.}
        else
          raise exception
        end
      end

      # ––––––––––
      # Conversion
      # ––––––––––

      def attributes_to_entity(attributes)
        entity_class.new attributes
      end

      def entity_to_record(entity, strip_id: false)
        attributes = entity.attributes
        if strip_id
          attributes.delete :id
          attributes.delete 'id'
        end
        backend.new attributes
      end

      def records_to_entities(records)
        return [] if records.blank?
        Array(records).map { |record| record_to_entity(record) }
      end

      def record_to_entity(record)
        return if record.blank?

        begin
          entity = entity_class.new record.attributes
        rescue ArgumentError => exception
          if exception.message.to_s == 'wrong number of arguments(1 for 0)'
            raise ArgumentError, %{The Class "#{entity_class}" appears not to be an Entity, because the initializer does not accept one argument. Did you "include Perimeter::Entity"?}
          else
            raise exception
          end
        end

        entity.id = record.id
        entity
      end

    end

  end
end
