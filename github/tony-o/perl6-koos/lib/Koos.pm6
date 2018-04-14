unit role Koos;

use DBIish;
use DBDish::Connection;

has $!db;
has $!driver;
has %!cache;
has $!connected;
has $!prefix;

multi method connect(Any:D: :$db, :%options) {
  $!db     = $db;
  $!driver = $!db.driver-name.split('::')[1];
  $!prefix = %options<prefix> // '';
  self.load-models;
}

multi method connect(Str:D :$driver, :%options) {
  #try {
    $!db        = DBIish.connect($driver, |%options<db>) or die $!;
    $!driver    = $driver;
    $!connected = True;
    $!prefix    = %options<prefix> // '';
    self.load-models;
  #  CATCH { default {
  #    if $_.^can('native-message') {
  #      warn ~$_.native-message.trim;
  #    } else {
  #      warn $_;
  #    }
  #  } }
  #}
}

method load-models() {
  my $base = $!prefix !~~ Nil ?? $!prefix !! ($?CALLERS::CLASS.^name//'');
  my @possible = try { CATCH { default {.say} }; "lib/{$base.subst('::', '/')}/Model".IO.dir.grep(
    * ~~ :f && *.extension eq any('pm6', 'pl6')
  ); } // [];
  for @possible -> $f {
    next unless $f.index("lib/$base") !~~ Nil;
    my $mod-name = $f.path.substr($f.index("lib/$base")+4, $f.rindex('.') - $f.index("lib/$base") - 4);
    $mod-name .=subst(/^^(\/|\\)/, '');
    $mod-name .=subst(/(\/|\\)/, '::', :g);
    try {
      my $m = (require ::($mod-name));
      %!cache{$mod-name.split('::')[*-1]} = $m.new(:$!driver, :$!db, :$!prefix, dbo => self);
      CATCH {
        default {
          #warn $_.backtrace.full;
        }
      }
    }
  }
}

method model(Str $model-name, Str :$module?) {
  if %!cache{$model-name}.defined {
    return %!cache{$model-name};
  }
  my $prefix = $!prefix !~~ Nil ?? $!prefix !! $?OUTER::CLASS.^name;
  my $model  = $module.defined ?? $module !! "$prefix\::Model\::$model-name";
  my $loaded = (try require ::("$model")) === Nil;
  if !$loaded {
    warn "Unable to load model: $model-name ($model)\n";
    return Nil;
  }
  try { 
    my $m = (require ::("$model"));
    %!cache{$model-name} = $m.new(:$!db, :$prefix, :$model-name, dbo => self);
    CATCH { default {
      say "Failed to load $model-name ($model)\n{$_}";
    } }
  }
  %!cache{$model-name};
}
