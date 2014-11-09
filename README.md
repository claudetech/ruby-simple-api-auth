# simple-api-auth [![Build Status](https://travis-ci.org/claudetech/ruby-simple-api-auth.svg?branch=master)](https://travis-ci.org/claudetech/ruby-simple-api-auth) [![Coverage Status](https://coveralls.io/repos/claudetech/ruby-simple-api-auth/badge.png?branch=master)](https://coveralls.io/r/claudetech/ruby-simple-api-auth?branch=master) [![Code Climate](https://codeclimate.com/github/claudetech/ruby-simple-api-auth/badges/gpa.svg)](https://codeclimate.com/github/claudetech/ruby-simple-api-auth)

This gem provides a very basic token based authentication
to use for API.
This is meant to be used as a lightweight authentication
solution when OAuth2 is too much.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple-api-auth'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple-api-auth

## Usage

This gem works out of the box with `ActiveRecord` and can be used stand alone
with a little more work.

### ActiveRecord usage

Just include `acts_as_api_authenticable` in your model.

```ruby
class User < ActiveRecord::Base
  acts_as_api_authenticable
end
```

you will need to have `ssa_key` and `ssa_secret` defined as strings
in your database for this to work. If you want to change the columns name,
you can pass them in option.

```ruby
class User < ActiveRecord::Base
  acts_as_api_authenticable ssa_key: :resource_key_field, ssa_secret: :secret_token
end
```

If you want the keys to be generated when you create a new instance of the model, you can pass `:auto_generate` with either `true`, or the field you want
to generate.

```ruby
class User < ActiveRecord::Base
  # this will generate a after_initialize to assign `ssa_key`
  acts_as_api_authenticable auto_generate: :ssa_key
  # this will generate a after_initialize for both `ssa_key` and `ssa_secret`
  acts_as_api_authenticable auto_generate: true
end
```

Note that the keys for autogenerate should be `:ssa_key` and `:ssa_secret` even if you change the key column name.

You can then use

```ruby
User.authenticate(request)
```

this will return the user if the request is valid, or `nil` otherwise.

### Standalone usage

This gem can easily used without `ActiveRecord`.

```ruby
ssa_key = SimpleApiAuth.extract_key(request)
secret_key = your_logic_to_get_secret_key(ssa_key)
valid = SimpleApiAuth.valid_signature?(request, secret_key)
```

### Configuration

The library accepts the following configurations

```ruby
SimpleApiAuth.configure do |config|
    # values used as default with `acts_as_api_authenticable`
    config.model_defaults = { ssa_key: :ssa_key, ssa_secret: :ssa_secret, auto_generate: false }

    # the normalized keys for the HTTP headers
    config.header_keys = { key: :x_saa_key, time: :x_saa_auth_time, authorization: :authorization
      }

    # the methods name for the HTTP request used
    config.request_fields = {
      headers: :headers,
      http_verb: :method,
      uri: :path,
      query_string: :query_string,
      body: :body
    }

    # the allowed HTTP methods
    config.allowed_methods = [:get, :post, :put, :patch, :delete]

    # the required headers for the HTTP request
    config.required_headers = config.header_keys.values

    # the class to use to hash requests
    # it must contain a `hmac` and a `hash` method
    config.hasher = SimpleApiAuth::Hasher::SHA1

    # the class to use to sign requests
    # it must contain a `sign` method
    config.signer = SimpleApiAuth::Signer
    config.request_timeout = 5
    config.logger = nil
end
```


### Supported frameworks

This library should be configurable enough to work with more or less any framework.
It will work out of the box for Rails, and will just need a little setup
to work with `request` objects with a different API.

For example, to work with Sinatra request, the following can be passed

```ruby
SimpleApiAuth.configure do |config|
  config.request_fields.merge! {
    headers: :env,
    http_verb: :request_method,
    uri: :path_info
  }
end
```

Note that `body` should return something with a `read` method,
and `query_string` should contain the URI encoded query string.

## Clients

This library can also be used as a client. You can compute the request
signature with

```ruby
signature = SimpleApiAuth.compute_signature(request, secret_key)
```

or directly sign the request with

```ruby
SimpleApiAuth.sign!(request, secret_key)
```

A JS client, with an AngularJS module intregrated with the `$http` service
is in progress and should be available soon (with a few weeks).

Contributions are very welcome for other clients.

## Contributing

1. Fork it ( https://github.com/claudetech/simple-api-auth/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
