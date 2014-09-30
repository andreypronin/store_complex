# StoreComplex

Stores complex data that includes Arrays and Hashes (possibly nested) in an attribute inside hstore field. The most typical usage scenario is storing arrays in hstore, but it can handle more complex cases. 

[![Build Status](https://travis-ci.org/moonfly/store_complex.svg?branch=master)](https://travis-ci.org/moonfly/store_complex)
[![Coverage Status](https://img.shields.io/coveralls/moonfly/store_complex.svg)](https://coveralls.io/r/moonfly/store_complex?branch=master)

## Installation

Add this line to your application's Gemfile:

    gem 'store_complex'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install store_complex

## Usage

### Reminder: What Rails already has

ActiveRecord in Rails 4 already provides methods for dealing with individual attributes inside [PostgresSQL hstore and json](http://www.postgresql.org/docs/9.3/static/hstore.html) fields.

Let's consider an example. There is a database table (and a corresponding ActiveRecord model) that describes some blog authors.
Among other data, it has an hstore field called `properties` that captures various optional bits of information about an author: 
email, facebook account, personal blog address, etc.

In Rails 4 you can get convenient access to the individual attributes inside `properties` using [`store_accessor`](http://api.rubyonrails.org/classes/ActiveRecord/Store.html):

```ruby
class Author < ActiveRecord::Base
  store_accessor :properties, :email, :facebook, :blog
end

author = Author.new(name:'Uber Guru')
author.properties                       # => nil
author.email = 'somebody@example.org'   # will store this email in properties
author.properties                       # => {"email"=>"somebody@example.org"}

author.save!

author = Author.find_by_name('Uber Guru')
author.properties                       # => {"email"=>"somebody@example.org"}
author.email                            # => 'somebody@example.org'
```

But what if we want to let tha authors specify more than a single email. OK, simple, the `email` property will now be an array. Not, so fast...

```ruby
author = Author.new(name:'Uber Guru')
author.properties                       # => nil
author.email = ['somebody@example.org','somebody@example.com']
author.properties                       # => {"email"=>["somebody@example.org", "somebody@example.com"]} 

author.save!

author = Author.find_by_name('Uber Guru')
author.properties                       # => {"email"=>"[\"somebody@example.org\", \"somebody@example.com\"]"}
author.email                            # => "[\"somebody@example.org\", \"somebody@example.com\"]"
# Oh-oh! :(
```

And instead of an array we got back a string representation of that array.

So, can we do something about it? Yes, meet `store_complex`...

### How to use `store_complex`

In your model, use `store_complex` in place of `store_accessor`. That's it!

```ruby
class Author < ActiveRecord::Base
  store_complex :properties, :email
end

author = Author.new(name:'Uber Guru')
author.properties                       # => nil
author.email = ['somebody@example.org','somebody@example.com']
author.properties                       # => {"email"=>["somebody@example.org", "somebody@example.com"]} 

author.save!

author = Author.find_by_name('Uber Guru')
author.properties                       # => {"email"=>"[\"somebody@example.org\", \"somebody@example.com\"]"}
author.email                            # => ["somebody@example.org","somebody@example.com"]
# Success! :)
```


### What `store_complex` does

`store_complex` allows to store arrays and hashes in hstore attributes. Those arrays and hashes can contain as their values or keys (for hashes):

- strings, numbers, booleans, nils - will be stored 'as is';
- other arrays and hashes - yes, nesting is possible;
- symbols - will be converted to strings;
- other data types if they can be converted to strings using `String(value)` - and yes, they **will** be converted to strings.

One important note: If you store something but array or hash, it will be wrapped into an array. `store_complex` is not for simple data types, use 'store_accessor' for that. The only exception is `nil`, which deletes the attribute from hstore. And if there is no attribute in hstore, the `store_complex` accessor will return an empty array: `[]`.

Example:

```ruby
class Author < ActiveRecord::Base
  store_complex :properties, :email
end

author = Author.new(name:'Uber Guru')

author.properties                       # => nil
author.email                            # => []

author.email = 'somebody@example.org'   #
author.email                            # => ["somebody@example.org"]

author.email = nil                      #
author.email                            # => []
```

Another awesome feature of `store_complex` is that it tracks not only assignments to the "complex" attribute, but also all operations on the hash or array (inlcuding those nested within!) that change the object (all those `sort!` and `delete` calls). Thanks to [observable_object gem](https://github.com/moonfly/observable_object) (and me as its author ;-) ) for that awesome behavior. 

To get you excited, here is an example below:

```ruby
class Author < ActiveRecord::Base
  store_complex :properties, :email
end

author = Author.new(name:'Uber Guru')

author.properties                             # => nil
author.email                                  # => []

author.email = { 
  "somebody@example.org" => "personal", 
  "somebody@example.com" => "work", 
  "somebody@business.nowhere" => "work"
}

author.email.delete_if { |k,v| v == 'work' }  # delete all work emails

author.save!

author = Author.find_by_name('Uber Guru')
author.email                                  # => {"somebody@example.org"=>"personal"} 
# Perfect!
```

## Versioning

Semantic versioning (http://semver.org/spec/v2.0.0.html) is used. 

For a version number MAJOR.MINOR.PATCH, unless MAJOR is 0:

1. MAJOR version is incremented when incompatible API changes are made,
2. MINOR version is incremented when functionality is added in a backwards-compatible manner, 
3. PATCH version is incremented when backwards-compatible bug fixes are made.

Major version "zero" (0.y.z) is for initial development. Anything may change at any time. 
The public API should not be considered stable. 

## Dependencies

- Ruby >= 2.1
- Rails >= 4.0
- observable_object

## Contributing

1. Fork it ( https://github.com/moonfly/store_complex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
