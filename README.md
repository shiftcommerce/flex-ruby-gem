# Flex::Commerce::Api

Allows any ruby application to use the FlexCommerce platform using its API

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'flex-commerce-api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install flex-commerce-api

## Usage

The gem provides many models in the FlexCommerce namespace. The example below is a rails controller
accessing a list of products.

```ruby
class ProductsController < ApplicationController

  # GET /products
  def index
    @products = FlexCommerce::Product.paginate(params[:page])
  end
end
```

To any rails developer this will look familiar.

However, we do not force you to use rails.  We appreciate that there are many frameworks out there
and whilst rails is an excellent tool, for smaller projects you may want to look at others such
as sinatra etc...


### Client IP address tracing in Rails apps


Add the request store gem to your Gemfile and install

```ruby
gem "request-store"
```

```sh
bundle install
```

```ruby
# application_controller.rb
class ApplicationController
  before_action :set_request_ip

  private

  def set_request_ip
    RequestStore[:request_ip] = request.remote_ip
  end
end
```

Configure the API client to pick up set value

```ruby
FlexCommerceApi.config do |config|
  config.forwarded_for = ->{ RequestStore[:request_ip] }
end
```



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/flex-commerce-api/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
