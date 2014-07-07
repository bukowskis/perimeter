require 'spec_helper'

require 'cities'
require 'cities/backend'
require 'admin/countries'
require 'admin/countries/backend'
require 'admin/cars'
require 'admin/vehicles/backend'

describe Perimeter::Repository do

  describe '.backend_class' do
    context 'in the root namespace' do
      it 'follows the Backend convention' do
        expect( Cities.backend_class ).to be Cities::Backend
      end
    end

    context 'in a custom namespace' do
      it 'follows the Backend convention' do
        expect( Admin::Countries.backend_class ).to be Admin::Countries::Backend
      end
    end

    context 'with custom backend class definitions' do
      it 'finds the right classe' do
        expect( Admin::Cars.backend_class ).to be Admin::Vehicles::Backend
      end
    end
  end

end
