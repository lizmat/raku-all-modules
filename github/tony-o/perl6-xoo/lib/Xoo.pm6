unit role Xoo;

use DBIish;
use DBDish::Connection;
use Xoo::Model;

has $!db;
has $!driver;
has %!cache;
has $!connected;
has $!prefix;

multi method connect(Any:D: :$db, :%options) {
  $!db     = $db;
  $!driver = $!db.driver-name.split('::')[1];
  $!prefix = %options<prefix> // '';
  self.load-models(%options<model-dirs>//[]);
}

multi method connect(Str:D :$driver, :%options) {
  $!db        = DBIish.connect($driver, |%options<db>) or die $!;
  $!driver    = $driver;
  $!connected = True;
  $!prefix    = %options<prefix> // '';
  self.load-models(%options<model-dirs>//[]);
}

method load-models(@model-dirs?) {
  my $base = $!prefix !~~ Nil ?? $!prefix !! ($?CALLERS::CLASS.^name//'');
  my @possible = try {
    CATCH {
      default {
        .say unless @model-dirs.elems;
      }
    };
    "lib/{$base.subst('::', '/')}/Model".IO.dir.grep(
      * ~~ :f && *.extension eq any('pm6', 'pl6')
    ) if "lib/{$base.subst('::', '/')}/Model".IO ~~ :d;
  } // [];
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
  if @model-dirs.elems {
    my $no-yaml = (try require ::('YAML::Parser::LibYAML')) === Nil;
    warn 'Cannot find YAML::Parser::LibYAML when attempting to load yaml models'
      if $no-yaml;
    unless $no-yaml {
      my $parser = ::('YAML::Parser::LibYAML::EXPORT::DEFAULT::&yaml-parse');
      for @model-dirs -> $dir {
        my @files = $dir.IO.dir;
        for @files -> $fil {
          next if $fil !~~ :f || $fil.extension ne 'yaml';
          my $mod = $parser.($fil.relative);
          my $name = $mod<name>//$mod<table>;
          my $new-model := Metamodel::ClassHOW.new_type(:name('Xoo::Model::'~$name));
          $new-model.HOW.add_attribute($new-model, Attribute.new(
            :name<@.columns>, :has_accessor(1), :type(Array), :package($new-model.WHAT),
          ));
          $new-model.HOW.add_attribute($new-model, Attribute.new(
            :name<@.relations>, :has_accessor(1), :type(Array), :package($new-model.WHAT),
          ));
          $new-model.^add_role(Xoo::Model[$mod<table>]);
          $new-model.HOW.compose($new-model);
          my @columns   = [ $mod<columns>.keys.map({ $_ => $mod<columns>{$_} }) ];
          my @relations = [ $mod<relations>.keys.map({ $_ => $mod<relations>{$_} }) ];
          %!cache{$name} = $new-model.new(driver => $!driver, :$!prefix, db => $!db, dbo => self, :@columns, :@relations);
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
      say "Failed to load $model-name ($model): {$_}";
    } }
  }
  %!cache{$model-name};
}
