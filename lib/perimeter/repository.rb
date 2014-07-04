module Perimeter
  module Repository
    extend ActiveSupport::Concern

    included do
      include Hooks
      define_hook :after_conversion
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

      private

      def default_backend_class
        backend_class_name = name + '::Backend'
        backend_class_name.constantize
      rescue NameError
        raise NameError, %{Repository "#{name}" expects the Backend "#{backend_class_name}" to be defined.}
      end

      def default_entity_class
        name.singularize.constantize
      rescue NameError
        raise NameError, %{Repository "#{name}" expects the Entity "#{name.singularize}" to be defined.}
      end

    end

    def backend_class
      self.class.backend_class
    end

    def entity_class
      self.class.entity_class
    end

    def backend_instances_to_entities(backend_instances)
      return [] unless backend_instances.present?
      entities = Array(backend_instances).map { |backend_instance| backend_instance_to_entity(backend_instance) }
      entities.length > 1 ? entities : entities.first
    end

    def backend_instance_to_entity(backend_instance)
      return nil unless backend_instance.present?
      entity = entity_class.new(backend_instance.attributes)
      run_hook :after_conversion, entity, backend_instance
      entity
    end
  end
end
