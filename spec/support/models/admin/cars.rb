require 'admin/vehicles/backend'
require 'admin/auto'

module Admin
  module Cars
    include Perimeter::Repository

    backend_class Vehicles::Backend
    entity_class  Auto

  end
end
