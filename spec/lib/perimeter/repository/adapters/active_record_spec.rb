require 'spec_helper'
require 'perimeter/repository/adapters/active_record'

require 'games'

describe Perimeter::Repository::Adapters::ActiveRecord do
  let(:id)                { '123-abc' }
  let(:record_attributes) { { id: id, name: 'Star Wars'} }
  let(:record)            { double(:record, attributes: record_attributes) }

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

      it 'is successful' do
        expect( finding ).to be_success
      end

      it 'has an informative code' do
        expect( code ).to eq :record_found
      end

      it 'holds the Entity' do
        expect( object ).to be_instance_of Game
      end

      it 'has all attributes on the Entity' do
        expect( object.attributes ).to eq record_attributes
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

      it 'is a failure' do
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
        allow( Games::Backend ).to receive(:find).and_raise EOFError
        expect( Trouble ).to receive(:notify)
      end

      it 'is an Operation' do
        expect( finding ).to be_instance_of Operation
      end

      it 'is a failure' do
        expect( finding ).to be_failure
      end

      it 'has an informative code' do
        expect( code ).to eq :backend_error
      end

      it 'holds the exception' do
        expect( object ).to be_instance_of EOFError
      end
    end

  end

end
