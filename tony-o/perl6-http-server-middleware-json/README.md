# HTTP::Server::Middleware::JSON

A JSON parser middleware for `HTTP::Server`s.

## Setup

```perl6
use HTTP::Server::Async;
use HTTP::Server::Middleware::JSON;

my HTTP::Server::Async $app .=new;

body-parse-json $app;

$app.handler: sub ($req, $res) {
  # may or may not have parsed JSON depending on Content-Type
}

$app.handler: $sub ($req, $res) is json-consumer {
  # trait<json-consumer>: calls a default or custom error handler for 
  #   invalid JSON found in the body of the request

  # if the request gets here then $req.params<body> represents the 
  #   parsed JSON data passed in the request body
}

# this is how to set a custom error handler for invalid or missing JSON
json-error sub ($req, $res) {
  #do your thing, the returned value is returned to the underlying HTTP::Server
  #  so it knows whether or not to continue processing
}
```
