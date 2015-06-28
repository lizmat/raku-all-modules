use HTTP::Server::Threaded;
use HTTP::Server::Router;

use Hiker::Model;
use Hiker::Route;
use Hiker::Render;

class Hiker {
  has Str  $.host;
  has Int  $.port;
  has Bool $.autobind;
  has      $.server;
  has      @!hikes;
  has      $.templates;

  submethod BUILD(:$!host? = '127.0.0.1', :$!port? = 8080, :@!hikes? = @('lib'), :$!autobind? = True, :$!server?, Str :$!templates = 'templates') {
    if $!server !~~ HTTP::Server::Threaded {
      $!server = HTTP::Server::Threaded.new(:ip($!host), :$!port);
    }
    if $!autobind {
      self.bind;
    }
    serve $!server;
  }

  method bind {
    my @ignore;
    my @routes;
    my $recurse = sub (*@m) {
      my @r;
      for @m -> $m {
        @r.push($m) unless @ignore.grep($m) || ::($m.^name) !~~ any(Hiker::Route, Hiker::Model);
        try @r.push($recurse($m.WHO.values)) if $m.WHO.values.elems;
      }
      return @r.flat;
    };
    for @($recurse(GLOBAL::.values)) {
      @ignore.push($_);
    }
    for @!hikes -> $d {
      try {
        for $d.IO.dir.grep(/ ('.pm6' | '.pl6') $$ /) -> $f {
          try {
            require $f;
            my @globmods = $recurse(GLOBAL::.values);
            for @globmods -> $module {  
              @ignore.push($module);
              try {
                next if ::($module.^name) ~~ Failure;
                @routes.push($f.Str => $module) if $module.^can('path');
              }
            }
          }
        }
      }
    }
    my $weight = sub ($_) {
      $_.value.new.path ~~ Regex ?? 1 !!
        $_.value.new.path.Str.index(':') ?? 0 !!
          -1;
    };
    @routes .=sort({ 
      $weight($^x) cmp $weight($^y);
    });
    for @routes {
      my ($f, $module) = $_.kv;
      try {
        "==> Binding {$module.perl} ...".say;
        my $obj = $module.new;
        if $obj ~~ Hiker::Route {
          die "{$module.perl} does not contain .path" unless $obj.path.defined;
          die "{$module.perl} requests model {$obj.model}" if $obj.^attributes.grep(.gist eq 'model') && ::($obj.model) ~~ Failure;
          "==> Setting up route {$obj.path ~~ Regex ?? $obj.path.gist !! $obj.path} ($f)".say;
          my $template = $obj.template;
          my $model;
          try {
            $model = ::($obj.model).new;
          }
          route $obj.path, sub ($req, $res) {
            "==> Serving {$req.uri} with {$f} :: {$module.^name}[{$obj.path ~~ Regex ?? $obj.path.gist !! $obj.path}]".say;
            CATCH { default {
              "==> Failed to serve {$req.uri}".say;
              $_.Str.lines.map({ "\t$_".say; });
              $_.backtrace.Str.lines.map({ "\t$_".say; });
            } }
            $res does Hiker::Render unless $res ~~ Hiker::Render;
            $res.req = $req;
            try {
              CATCH { default { .say; } }
              $model.bind($req, $res) if $model.defined;
            }
            $res.template = $*SPEC.catpath('', $.templates, $template);
            my $lval = $obj.handler($req, $res);
            await $lval if $lval ~~ Promise;
            $lval = $lval.status.result if $lval ~~ Promise;
            return True if $res.rendered;
            $res.render if $lval && !so $res.rendered;
            return $lval;
          }
        }
        CATCH { default {
          "==> Failed to bind {$module.perl}".say;
          $_.Str.lines.map({ "\t$_".say; });
          $_.backtrace.Str.lines.map({ "\t$_".say; });
        } }
      } 
    }
  }

  method listen(Bool $async? = False) {
    if $async {
      return start { $.server.listen; };
    }
    $.server.listen;
  }
}
