require 'spec_helper'
require 'perimeter/repository/adapters/active_record'

require 'games'

describe Perimeter::Repository::Adapters::ActiveRecord do
  let(:id)         { '123-abc' }
  let(:attributes) { { id: id, name: 'Star Wars', genre: 'Classic' } }
  let(:record)     { double :record, id: id, attributes: attributes }

  describe '.find' do
    let(:finding) { Games.find id }
    let(:object)  { finding.object }
    let(:code)    { finding.code }

    context 'the record exists' do
      before do
        expect( Trouble).to_not receive :notify
        allow( Games::Backend ).to receive(:find).and_return record
      end

      it 'is an Operation' do
        expect( finding ).to be_instance_of Operation
      end

      it 'succeeds' do
        expect( finding ).to be_success
      end

      it 'has an informative code' do
        expect( code ).to eq :record_found
      end

      it 'holds the Entity' do
        expect( object ).to be_instance_of Game
      end

      it 'has all attributes on the Entity' do
        expect( object.attributes ).to eq attributes
      end
    end

    context 'the record does not exist' do
      before do
        expect( Trouble).to_not receive :notify
        allow( Games::Backend ).to receive(:find).and_raise ::ActiveRecord::RecordNotFound
      end

      it 'is an Operation' do
        expect( finding ).to be_instance_of Operation
      end

      it 'fails' do
        expect( finding ).to be_failure
      end

      it 'has an informative code' do
        expect( code ).to eq :record_not_found
      end

      it 'holds the exception' do
        expect( object ).to be_instance_of ::ActiveRecord::RecordNotFound
      end
    end

    context 'the backend had problems' do
      before do
        allow( Games::Backend ).to receive(:find).and_raise NoMemoryError
        expect( Trouble ).to receive(:notify)
      end

      it 'is an Operation' do
        expect( finding ).to be_instance_of Operation
      end

      it 'fails' do
        expect( finding ).to be_failure
      end

      it 'has an informative code' do
        expect( code ).to eq :backend_error
      end

      it 'holds the exception' do
        expect( object ).to be_instance_of NoMemoryError
      end
    end
  end

  describe '.find!' do
    let(:finding) { Games.find! id }

    context 'the record exists' do
      before do
        expect( Trouble).to_not receive :notify
        allow( Games::Backend ).to receive(:find).and_return record
      end

      it 'is an Entity' do
        expect( finding ).to be_instance_of Game
      end

      it 'has all attributes on the Entity' do
        expect( finding.attributes ).to eq attributes
      end
    end

    context 'the record does not exist' do
      before do
        expect( Trouble).to_not receive :notify
        allow( Games::Backend ).to receive(:find).and_raise ::ActiveRecord::RecordNotFound
      end

      it 'raises an Exception' do
        expect { finding }.to raise_error Perimeter::Repository::FindingError
      end
    end

    context 'the backend had problems' do
      before do
        allow( Games::Backend ).to receive(:find).and_raise IOError
        expect( Trouble ).to receive(:notify)
      end

      it 'raises an Exception' do
        expect { finding }.to raise_error Perimeter::Repository::FindingError
      end
    end
  end

  describe '.create' do
    let(:attributes) { { name: 'Titanic', genre: 'Romance' } }
    let(:creation) { Games.create attributes }
    let(:object)   { creation.object }
    let(:code)     { creation.code }

    context 'both Entity and Record are invalid' do
      let(:attributes) { {} }

      it 'is an Operation' do
        expect( creation ).to be_instance_of Operation
      end

      it 'fails' do
        expect( creation ).to be_failure
      end

      it 'has an informative code' do
        expect( code ).to eq :validation_failed
      end

      it 'knows the validation that failed on both Entity and Record' do
        expect( object.errors.count ).to eq 2
        expect( object.errors[:name] ).to be_present
        expect( object.errors[:genre] ).to be_present
      end

      it 'has all attributes on the Entity' do
        expect( object.attributes ).to eq id: nil, name: nil, genre: nil
      end
    end

    context 'only the Entity is invalid' do
      let(:attributes) { { genre: 'Sci-Fi' } }

      it 'is an Operation' do
        expect( creation ).to be_instance_of Operation
      end

      it 'fails' do
        expect( creation ).to be_failure
      end

      it 'has an informative code' do
        expect( code ).to eq :validation_failed
      end

      it 'knows the validation that failed on the Entity' do
        expect( object.errors.count ).to eq 1
        expect( object.errors[:name] ).to be_present
      end

      it 'has all attributes on the Entity' do
        expect( object.attributes ).to eq id: nil, name: nil, genre: 'Sci-Fi'
      end
    end

    context 'only the Record is invalid' do
      let(:attributes) { { name: 'Transformers' } }

      it 'is an Operation' do
        expect( creation ).to be_instance_of Operation
      end

      it 'fails' do
        expect( creation ).to be_failure
      end

      it 'has an informative code' do
        expect( code ).to eq :validation_failed
      end

      it 'knows the validation that failed on the Entity' do
        expect( object.errors.count ).to eq 1
        expect( object.errors[:genre] ).to be_present
      end

      it 'has all attributes on the Entity' do
        expect( object.attributes ).to eq id: nil, name: 'Transformers', genre: nil
      end
    end

    context 'record already exists' do
      before do
        allow( Games::Backend ).to receive(:new).with(attributes).and_return record
        allow( Games::Backend ).to receive(:find_by_id).with(id).and_return record
        allow( record ).to receive(:invalid?).and_return false
      end

      it 'is an Operation' do
        expect( creation ).to be_instance_of Operation
      end

      it 'fails' do
        expect( creation ).to be_failure
      end

      it 'has an informative code' do
        expect( code ).to eq :record_already_exists
      end
    end

    context 'persistence fails' do
      before do
        allow( Games::Backend ).to receive(:new).with(attributes).and_return record
        allow( Games::Backend ).to receive(:find_by_id)
        allow( record ).to receive(:invalid?).and_return false
        allow( record ).to receive(:save)
      end

      it 'is an Operation' do
        expect( creation ).to be_instance_of Operation
      end

      it 'fails' do
        expect( creation ).to be_failure
      end

      it 'has an informative code' do
        expect( code ).to eq :creation_failed
      end
    end

    context 'persistence succeeds' do
      let(:record) { double(:record, id: nil, invalid?: false) }

      before do
        allow( Games::Backend ).to receive(:new).with(attributes).and_return record
        allow( record ).to receive(:save) do |args|
          allow( record ).to receive(:id).and_return 'newly-created-id'
          allow( record ).to receive(:attributes).and_return attributes.merge(id: 'newly-created-id')
          true
        end
      end

      it 'is an Operation' do
        expect( creation ).to be_instance_of Operation
      end

      it 'succeeds' do
        expect( creation ).to be_success
      end

      it 'has an informative code' do
        expect( code ).to eq :record_created
      end

      it 'holds the Entity' do
        expect( object ).to be_instance_of Game
      end

      it 'has all attributes on the Entity' do
        expect( object.attributes ).to eq attributes.merge(id: 'newly-created-id')
      end
    end

  end

end
