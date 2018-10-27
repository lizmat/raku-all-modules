use HTTP::Server::Router;
use YAML::Parser::LibYAML;
use HTTP::Server;

module HTTP::Server::Router::YAML {
  my @servers;
  
  sub serve(HTTP::Server $s) is export {
    serve $s;
  }

  sub route-yaml(Str $yaml-path, Bool $DEBUG = False) is export {
    die "Unable to find yaml file: {$yaml-path.IO.absolute}" 
      unless $yaml-path.IO:e;
    my $route-info = yaml-parse $yaml-path;
    for $route-info<paths>.kv -> $path, $attr {
      try {
        my $module = $attr<controller>;
        my $sub    = $attr<sub>;
        "Attempting to require $module".say if $DEBUG;
        require ::($module);
        "Attempting to reference {$module}::EXPORT::DEFAULT::&{$sub}".say if $DEBUG;
        $sub = ::("{$module}::EXPORT::DEFAULT::&{$sub}");
        "Routing $path.".say if $DEBUG;
        route $path, $sub;
      };
    }
  }

};
