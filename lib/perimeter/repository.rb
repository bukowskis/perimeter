require 'hooks'

module Perimeter
  module Repository

    def self.included(base)
      base.extend ClassMethods

      base.class_eval do
        include ::Hooks
        define_hook :after_conversion
      end
    end

    module ClassMethods

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
          raise NameError, %{Repository "#{name}" expects the Backend "#{entity_class_name}" to be defined.}
        else
          raise exception
        end
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

        run_hook :after_conversion, entity, record
        entity
      end

    end

  end
end
