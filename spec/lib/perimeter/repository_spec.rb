require 'spec_helper'

require 'cities'
require 'songs'
require 'admin/countries'
require 'admin/cars'

describe Perimeter::Repository do

  describe '.backend_class' do
    context 'in the root namespace' do
      it 'follows the Backend convention' do
        expect(Cities.backend_class).to be Cities::Backend
      end
    end

    context 'in a custom namespace' do
      it 'follows the Backend convention' do
        expect(Admin::Countries.backend_class).to be Admin::Countries::Backend
      end
    end

    context 'with custom backend class definitions' do
      it 'finds the right classe' do
        expect(Admin::Cars.backend_class).to be Admin::Vehicles::Backend
      end
    end
  end

  describe '.backend' do
    it 'is a (read-only) shortcut to #backend_class' do
      expect(Cities).to receive(:backend_class).and_return 'backend_class says hello'
      expect(Cities.backend).to eq 'backend_class says hello'
    end

    it 'refuses to take arguments' do
      expect { Cities.backend 'something custom' }.to raise_error(ArgumentError)
    end
  end

  describe '.entity_to_record' do
    it 'runs the after_conversion hook' do
      expect(Songs.my_favorite_song.title).to eq "I'm singing in the rain (2:00)"
    end
  end

end
