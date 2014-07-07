module Perimeter
  module Backend
    module Adapters
      module ActiveRecord

        def self.included(base)
          base.extend ClassMethods

          base.class_eval do
            set_table_name perimeter_table_name
          end
        end

        module ClassMethods

          def perimeter_table_name(*args)
            @perimeter_table_name = args.first unless args.empty?
            @perimeter_table_name || default_perimeter_table_name
          end

          def default_perimeter_table_name
            name.split('::')[-2].underscore
          end

        end

      end
    end
  end
end
