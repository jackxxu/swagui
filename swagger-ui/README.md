swagger_ui2
==========

A slight modification on swagger ui to add a __discrete__ UI layer on top of a swagger 2.0 spec json resource.

### Usage

1. Pass in the full url to the json as `baseurl` query param. This is compatible with how swagger ui has been working. For example:

```
https://github.comcast.com/pages/jxu001c/swagger_ui2/?baseurl=https://github.comcast.com/xbo/sat-gen/raw/gh-pages/swagger.json

```

2. From a github page, pass in relative path of the json in the repo as `base` query param and link to it from the README.md. this allows in-branch swagger documentation. for example:

```
https://github.comcast.com/pages/jxu001c/swagger_ui2/?base=/doc/swagger.json
```

### Assumptions

the user agent needs to be logged in to Comcast Github Enterprise.

### Special Thanks

Thanks to @Jwinte00c for his insights on Github raw url redirection.
