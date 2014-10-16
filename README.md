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

### doc file format

`Swagui` supports three types of doc format

1. JSON documents with no extension ([original swagger doc format]), such as `api-docs` and `account`.
2. JSON documents with `.json` extension, such as `api-docs.json` and `account.json`.
3. YAML documents. This the recommended approach as it is naturally more concise than json and also tries to be more opinionated in the following ways:
   1. __auto listing__: if not provided in `api-docs.yml`, the list of apis under `apis` is automatically populated by the names of all the .yml files in the same directory.
   2. __auto "Try it out"__: the `basePath` attribute of each doc, used for `try it out` feature, if unprovided, is automatically provided based on the host application. this assumes the doc is hosted as part of the application.
   3. __schema-based models__: to circumvent all the rather complex and tedious syntax for `models`, schema attributes under `apis/operations/parameters` (for request body json schema) and `apis/operations/responseMessages` (for response body json schema), and it will be used to automatically populate the `models` under root.
   4. __template__: in `api-docs.yml`, a `template` section can be added that lists all the general attributes for all the apis, for example if you apis is a JSON api, chances are that they all consumes JSON requests and produces JSON responses. IN this case, instead of adding the following line in each service yml file, you can simply add this section to `api-docs.yml`.

```javascript
  template:
    produces:
      - application/json
    consumes:
      - application/json
```

With this approach, swagger api docs are now a lot more concise and readible, let alone having dynamic `basePath`.

#### sample api-docs.yml
```yaml
---
  info:
    title: "a sojourner's api"
    description: "Ut? Amet, et eros nascetur parturient diam scelerisque, egestas, pulvinar sit cum, rhoncus eros vel urna aliquam massa! Turpis purus auctor proin aliquam nunc, nec proin vel enim est, scelerisque! Ac vel integer proin sed in."
    contact: "sojourner@world.net"
  apiVersion: "1.0.0"
  swaggerVersion: "1.2"
  authorizations: {}

```
#### sample account.yml
```yaml
---
  produces:
    - application/json
  apis:
    -
      path: /account
      description: create or update a account
      operations:
        -
          method: POST
          summary: create or update an account
          nickname: PostAccount
          parameters:
            -
              name: body
              required: true
              schema: test/doc/schemas/account_post_request_body.schema.json
              paramType: body
          responseMessages:
            -
              code: 200
              message: account creation success
              schema: test/doc/schemas/account_post_creation_success.schema.json
            -
              code: 400
              message: account creation failure
              schema: test/doc/schemas/account_post_creation_failure.schema.json

```



### Command-line utility

Sometimes, you only want to see the documentation without starting the entire application. All you need to do is to run the following command in your documentation directory:

    $ bundle exec swagui

optionally, you can specify the directory name as a command line argument:

    $ bundle exec swagui doc

You will then able to view the [swagger-ui] loaded with your api documentation at `http://localhost:9292`

[swagger-ui]: https://github.com/wordnik/swagger-ui
[original swagger doc format]: https://github.com/wordnik/swagger-spec/blob/master/fixtures/v1.2/helloworld/static/api-docs
## Contributing

1. Fork it ( https://github.com/jackxxu/swagui/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

