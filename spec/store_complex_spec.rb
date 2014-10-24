require 'spec_helper'

class ARSomething < ActiveRecord::Base
end

class Something
  extend StoreComplex::Accessor
  def test_hstore
    $test_hstore ||= {}
  end
  def test_hstore=(value)
    $test_hstore = value
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
end

RSpec.describe StoreComplex::Accessor do
  let(:obj) { Something.new }
  let(:obj1) { Something.new }
  it 'injects its methods into ActiveRecord' do
    expect(ARSomething.methods).to include *StoreComplex::Accessor.instance_methods
  end
  it 'allows to store arrays in the store' do
    value = [1,'a',true]
    obj.test_attr = value
    expect( obj.test_attr ).to eq value
  end
  it 'allows to store hashes in the store' do
    value = {'a'=>'b','c'=>12}
    obj.test_attr = value
    expect( obj.test_attr ).to eq value
  end
  it 'allows to store sets in the store as arrays' do
    value = Set[1,'a',true]
    obj.test_attr = value
    expect( obj.test_attr ).to eq value.to_a
  end
  it 'allows to store strings wrapped in an array' do
    value = 'string'
    obj.test_attr = value
    expect( obj.test_attr ).to eq [value]
  end
  it 'allows to store integers wrapped in an array' do
    value = 198
    obj.test_attr = value
    expect( obj.test_attr ).to eq [value]
  end
  it 'converts symbols to strings when storing' do
    value = [:a,:b]
    obj.test_attr = value
    expect( obj.test_attr ).to eq value.map(&:to_s)

    value = {a:1}
    obj.test_attr = value
    expect( obj.test_attr ).to eq value.map { |k,v| [k.to_s,v] }.to_h
  end
  it 'detects changes to the stored hashes' do
    obj.test_attr = {'a'=>2,'b'=>4}
    obj.test_attr.delete('a')
    expect( obj1.test_attr ).to eq( {'b'=>4} )
  end
  it 'detects changes to the stored arrays' do
    obj.test_attr = [1,10,8,55]
    obj.test_attr.sort!
    expect( obj1.test_attr ).to eq [1,8,10,55]
  end
  it 'detects changes to the stored sub-arrays' do
    obj.test_attr = [[1,10,8,55],[2,19,88,7]]
    obj.test_attr[1].sort!
    expect( obj1.test_attr ).to eq [[1,10,8,55],[2,7,19,88]]
  end
  it 'detects changing an element in a sub-element' do
    obj.test_attr = { 'a' => [1,2], 'b' => [3,4], 'c' => [5,6] }
    obj.test_attr['b'][1] = 10
    expect( obj1.test_attr ).to eq( { 'a' => [1,2], 'b' => [3,10], 'c' => [5,6] } )
  end
  it 'detects changes to the added element of a stored array' do
    obj.test_attr = [[1,10,8,55],[2,19,88,7]]
    obj.test_attr << [3,0,7]
    obj.test_attr[2].sort!
    expect( obj1.test_attr ).to eq [[1,10,8,55],[2,19,88,7],[0,3,7]]
  end
  it 'detects changes to the stored strings' do
    obj.test_attr = ['some string']
    obj.test_attr[0].upcase!
    expect( obj1.test_attr ).to eq ['SOME STRING']
  end
end