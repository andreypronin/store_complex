require 'spec_helper'

class Something < ActiveRecord::Base
  def test_hstore
    @test_hstore ||= {}
  end
  store_complex :test_hstore, :test_attr
end

RSpec.describe 'StoreComplex::obj_to_store' do
  it 'converts nil to nil' do
    expect( StoreComplex::obj_to_store(nil) ).to eq nil
  end
  it 'converts single value to array' do
    expect( JSON.parse( StoreComplex::obj_to_store(1)) ).to eq [1]
  end
  it 'converts array to itself' do
    expect( JSON.parse( StoreComplex::obj_to_store(['a',1]) ) ).to eq ['a',1]
  end
  it 'converts empty array to itself' do
    expect( JSON.parse( StoreComplex::obj_to_store([]) ) ).to eq []
  end
  it 'converts Set to array' do
    expect( JSON.parse( StoreComplex::obj_to_store(Set['a',1]) ) ).to eq ['a',1]
  end
  it 'converts hash to itself' do
    expect( JSON.parse( StoreComplex::obj_to_store( {'a'=>1} ) ) ).to eq( {'a'=>1} )
  end
  it 'converts symbol keys in hash to strings' do
    expect( JSON.parse( StoreComplex::obj_to_store( {a:1} ) ) ).to eq( {'a'=>1} )
  end
end

RSpec.describe 'StoreComplex::store_to_obj' do
  it 'converts nil to empty array' do
    expect( StoreComplex::store_to_obj(nil) ).to eq []
  end
  it 'parses from JSON for non-nil arrays' do
    value = [{'x'=>1},'string',11.67]
    jval = JSON.generate value
    expect( StoreComplex::store_to_obj(jval) ).to eq value
  end
  it 'parses from JSON for non-nil hashes' do
    value = {'x'=>1,'string'=>11.67,'7'=>true}
    jval = JSON.generate value
    expect( StoreComplex::store_to_obj(jval) ).to eq value
  end
end

RSpec.describe StoreComplex do
  it 'has a version (smoke test)' do
    expect(StoreComplex::VERSION).to be_a String
  end
  it 'injects its methods into ActiveRecord' do
    expect(Something.methods).to include *StoreComplex::Accessor.instance_methods
  end
end