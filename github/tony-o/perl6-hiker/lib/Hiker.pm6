use HTTP::Server::Async;
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
    if $!server !~~ HTTP::Server::Async {
      $!server = HTTP::Server::Async.new(:ip($!host), :$!port);
    }
    if $!autobind {
      self.bind;
    }
    serve $!server;
  }

  method bind {
    my @ignore;
    my @routes;
    my @models;
    my $recurse = sub (*@m) {
      my @r;
      for @m -> $m {
        next unless $m ~~ Pair;
        CATCH { default { warn $_; } }
        @r.append($m.value) 
          unless @ignore.grep($m.key) 
              || (
                $m.value !~~ any(Hiker::Route, Hiker::Model)
              );
        try @r.append($recurse($m.value.WHO)) 
          if $m.value.WHO.values.elems;
      }
      return @r.flat;
    };
    for @($recurse(DYNAMIC::.values)) {
      @ignore.append($_.key) if $_ ~~ Pair;
    }
    my @globmods;
    for @!hikes -> $d {
      try {
        for $d.IO.dir.grep(/ ('.pm6' || '.pl6') $$ /).Slip -> $f {
          try {
            (try require "{$f.absolute}") === Nil and die "could not load {$f.absolute}";
            @globmods.push( $f => $recurse(DYNAMIC::.values).flat );
            CATCH { default { warn $_; } }
          }
        }
      }
    }
    for @globmods -> $module {  
      try {
        next if ::($module.^name) ~~ Failure;
        for $module.value.cache -> $mod {
          @routes.append($module.key => $mod) if $mod ~~ Hiker::Route;
          @models.append($module.key => $mod) if $mod ~~ Hiker::Model;
        }
        CATCH { default { warn $_; } }
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
          die "{$module.perl} does not contain .path" 
            unless $obj.path.defined;
          die "{$module.perl} requests model {$obj.model}" 
            if $obj.^attributes.grep({ .gist eq 'model' }) 
            && ::($obj.model) ~~ Failure;
          "==> Setting up route {$obj.path ~~ Regex ?? $obj.path.gist !! $obj.path} ($f)".say;
          my $template = $obj.template;
          my $model;
          try {
            CATCH { default { warn $_; } }
            $model = .values.grep({ .^name eq ( $obj.^can('model') ?? $obj.model !! '' ) })[0].new 
              for @models;
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

  method listen(Bool :$block = False) {
    my $prom = $.server.listen;
    await $prom if $block;
    $prom;
  }
}
