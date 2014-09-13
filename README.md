# Swagui

a Rack middleware app and a command-line utility that helps you render [swagger-ui], a great api documentation tool, with ease and grace.

## Install
Add this line to your application's Gemfile:

```ruby
group :development do
  gem 'swagui'
end
```

## Usage

### Rack middleware

In your `application.rb` (for Rails app) or `config.ru` (for Rack app), add Swigui middleware close to the top of the middleware stack. For example, in a `config.ru` file, add the following line:

```ruby
if Rack.env == 'development'
  use Swagui::App, url: '/doc', path: 'doc'
end
```

* `url`: the url path to access the [swagger-ui].
* `path`: the sub-directory name where the swagger files are stored. It assumes that `api-docs` is the index file in the directory.
* basic auth block: in case the doc site need to be protected by http basic auth, you can configure it by a block, for example:

```ruby
  use Swagui::App, url: '/doc', path: 'doc' do |username, password|
    [username, password] == ['admin', 'admin']
  end
```

You will be able to access the [swagger-ui] loaded with your api documentation at `/doc` (your `url` setting) when the server starts.

### Command-line utility

Sometimes, you only want to see the documentation without starting the entire application. All you need to do is to run the following command in your documentation directory:

    $ bundle exec swagui

optionally, you can specify the directory name as a command line argument:

    $ bundle exec swagui doc

You will then able to view the [swagger-ui] loaded with your api documentation at `http://localhost:9292`

[swagger-ui]: https://github.com/wordnik/swagger-ui

## Contributing

1. Fork it ( https://github.com/jackxxu/swagui/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
