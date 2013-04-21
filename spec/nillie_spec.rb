require 'rspec/mocks'

require 'nillie'

describe nil do
  describe '.method_missing' do

    context "when sending a message which can't be responded" do
      let( :sent_method ){ :non_existing_method }
      it { expect { nil.__send__ sent_method }.to raise_error NilError::NoMethod }

      describe 'the raised error' do
        subject do
          begin
            nil.__send__ sent_method
          rescue NilError::NoMethod => subject_error
            subject_error
          end
        end
        its( :sent_method ){ should be sent_method }
      end
    end
  end
end

describe Nillie do
  describe '.catches' do
    describe 'inside the given block,' do
      context 'when a non exisiting method called on nil' do
        let( :some_object ){ double( 'some_object', some_method_which_can_return_nil: nil ) }
        subject do
          Nillie.catches do
            some_object.some_method_which_can_return_nil.some_chained_method
          end
        end
        it { should be_instance_of Nillie::InvalidType }
        its( :sent_method ){ should be :some_chained_method }
        it { should_not be_type_error }
      end

      context 'when nil is given as an invalid argument of some method' do
        let( :some_array ){ [1] }
        subject do
          Nillie.catches do
            some_array[nil]
          end
        end
        it { should be_instance_of Nillie::InvalidType }
        its( :sent_method ){ should be_nil }
        it { should be_type_error }
      end
    end
  end
end
