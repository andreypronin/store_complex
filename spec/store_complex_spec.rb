require 'spec_helper'

class Something < ActiveRecord::Base
  def test_hstore
    @test_hstore ||= {}
  end
  store_complex :test_hstore, :test_attr
end

RSpec.describe StoreComplex do
  it 'has a version' do
    expect(StoreComplex::VERSION).to be_a String
  end
  it 'injects its methods into ActiveRecord' do
    expect(Something.methods).to include *StoreComplex::Accessor.instance_methods
  end
end