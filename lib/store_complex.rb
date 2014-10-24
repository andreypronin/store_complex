require 'store_complex/version'
require 'observable_object'
require 'active_record'
require 'json'

module StoreComplex
  def self.obj_to_store(value)
    return nil if value.nil?
    JSON.generate(value.is_a?(Hash) ? value : Array(value))
  end
  def self.store_to_obj(value)
    return [] if value.nil?
    JSON.parse(value)
  end
  
  module Accessor
    def store_complex(store_name,*attr_names)
      attr_names.each do |name|
        attr_set = name.to_s+'='
        
        define_method(name) do
          value = (self.send(store_name) || {})[name.to_s]
          ObservableObject::deep_wrap( StoreComplex::store_to_obj(value) ) { |obj| self.send(attr_set, obj) }
        end
        
        define_method(attr_set) do |value|
          store = self.send(store_name) || {}
          store[name.to_s] = StoreComplex::obj_to_store(value)
          self.send(store_name.to_s+'=',store)
        end
      end
    end
  end
end

ActiveRecord::Base.extend StoreComplex::Accessor
