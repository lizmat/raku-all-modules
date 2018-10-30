# A simply YAML router for HTTP::Server::Router

A simple YAML router for `HTTP::Server::Router`

## Usage

```perl6
use HTTP::Server::Router::YAML;
use HTTP::Server::Async;

my $s = HTTP::Server::Async.new;

serve $s;
route-yaml 'route1.yaml';

$s.listen(True);
```

```yaml
---
paths:
  /test: # this is the path, you can use :placeholders too
    controller: Whatever #an attempt to require this module will be made
    sub:        test     #this is the method in the module that the requests
                         #   to path will passed along to
```

# Methods

# serve

This method expects an `HTTP::Server` as an argument and will bind itself to whatever server(s) is supplied.

# route-yaml (Str $path-to-yaml-file)

This method will attempt to parse the yaml file and bind any paths possible

# credits

tony-o
