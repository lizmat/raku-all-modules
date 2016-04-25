unit class Flower::TAL::TALES; ## Parses TALES strings, used by TAL.

use MONKEY-SEE-NO-EVAL;

use XML;
use Flower::TAL::TALES::Default; ## The default TALES parsers.

has @!plugins;  ## Our private list of plugins. Use add-plugin() to add more.
has $.parent;   ## The XML Lang that called us. Probably Flower::TAL::TAL
has $.flower;   ## The top-most Flower object.

submethod BUILD (:$parent) {
  $!parent = $parent;
  $!flower = $parent.flower; 
  my $default = Flower::TAL::TALES::Default.new(:tales(self), :$!flower);
  @!plugins = $default;
}

## Add a TALES plugin to our list.
## Can take an object instance, a Type object, or a string.
## If you use a string without a :: separator in it, the
## prefix Flower::TAL::TALES:: is added to it.
## Note: due to rakudo bugs, using a string plugin currently has
## the following limitations:
##   - The plugin's $.flower and $.tales attributes must be "rw".
##   - They must not refer to $.flower or $.tales in any BUILD submethods.
method add-plugin ($plugin) {
  my $object = $plugin;
  if $plugin ~~ Str {
    my $plugname;
    if $plugin !~~ /'::'/ { ## If there's no namespace, we add one.
      $plugname = "Flower::TAL::TALES::$plugin";
    }
    else {
      $plugname = $plugin;
    }
    if $plugname eq 'Flower::TAL::TALES::Default' { return; }
### This doesn't work in rakudo yet.
#    require $plugname;
#    $object = ::($plugname).new(:tales(self), :flower($.flower));
### So we use the evil workaround instead.
    EVAL("use $plugname; \$object = {$plugname}.new;"); ## EVIL!
    if $object ~~ Str { die "Loading '$plugname' failed."; }
    $object.tales = self; ## More evil, $.tales should not be rw.
    $object.flower = $.flower; ## Yet more evil, $.flower should not be rw.
  }
  elsif ! $plugin.defined {
    $object = $plugin.new(:tales(self), :flower($.flower));
  }
  ## Add the plugin.
  if $object.defined {
    @!plugins.push: $object;
  }
}

## Query data.
method query ($query is copy, :$noxml, :$forcexml, :$bool, :$noescape is copy) {
  if $query eq '' { 
    if ($bool) { return True; }
    else       { return '';   }
  }
  if $query eq 'nothing' { 
    if ($bool) { return False; }
    else       { return '';    }
  }
  if $query eq 'default' {
    my $default = $.flower.elements[0].nodes;
    return $default;
  }
  if $query ~~ /^ structure \s+ / {
    $query.=subst(/^ structure \s+ /, '');
    $noescape = True;
  }
  if $query ~~ /^\'(.*?)\'$/ {
    return self.process-query(~$0, :$forcexml, :$noxml, :$noescape);
  } # quoted string, no interpolation.
  if $query ~~ /^<.ident>+\:/ {
    my ($handler, $subquery) = $query.split(/\:\s*/, 2);
    for @!plugins -> $plugin {
      if $plugin.handlers{$handler} :exists {
        my $method = $plugin.handlers{$handler};
        ## Modifiers are responsible for subqueries and process-query calls.
        return $plugin."$method"($subquery, :$noxml, :$forcexml, :$bool, :$noescape);
      }
    }
  }
  my @paths = $query.split('/');
  my $data = self!lookup(@paths, $.flower.data);
  return self.process-query($data, :$forcexml, :$noxml, :$noescape);
}

## Enforce processing rules for query().
method process-query($data is copy, :$forcexml, :$noxml, :$noescape, :$bool) 
{
  ## First off, let's escape text, unless noescape is set.
  if (! $noescape && $data ~~ Str) 
  {
    $data.=subst(/'&' [<!before \w+ ';'>]/, '&amp;', :g);
    $data.=subst('<', '&lt;', :g);
    $data.=subst('>', '&gt;', :g);
    $data.=subst('"', '&quot;', :g);
  }
  ## Default rule for forcexml converts non-XML objects into XML::Text.
  if ($forcexml) {
    if ($data ~~ Array) {
      for @($data) -> $elm is rw {
        if $elm !~~ XML { $elm = XML::Text.new(:text(~$elm)); }
      }
      return $data;
    }
    elsif ($data !~~ XML) {
      return XML::Text.new(:text(~$data));
    }
  }
  elsif ($noxml && $data !~~ Str|Numeric) {
    return; ## With noxml set, we only accept Strings or Numbers.
  }
  return $data;
}

## get-args now supports parameters in the form of {{param name}} for
## when you have nested queries with spaces in them that shouldn't be treated
## as strings, like 'a string' does. It also captures ${vars} and does no
## processing on them unless you are using string processing (see below.)
## It also supports named parameters in the form of :param(value).
## If the :query option is set, all found parameters will be looked up using
## the query() method (with default options.)
## If :query is set to a Hash, then the keys of the Hash represent positional
## parameters (the first positional parameter is 0 not 1.)
## the value represents an action to take, if it is 0, then no querying or
## parsing is done on the value. If it is 1, then the value is parsed as a
## string with any ${name} variables queried.
## If there is a key called .STRING in the query Hash, then parsing as
## strings becomes default, and keys with a value of 1 parse as normal queries.
## so :query({0=>0, 3=>0}) would query all parameters except the 1st and 4th.
## If you specify the :named option, it will always include the %named
## parameter, even if it's empty.
method get-args($string, :$query, :$named, *@defaults) {
  my @result = 
    $string.comb(/ [ '{{'.*?'}}' | '${'.*?'}' | '$('.*?')' | ':'\w+'('.*?')' | \'.*?\' | \S+ ] /);
  @result>>.=subst(/^'{{'/, '');
  @result>>.=subst(/'}}'$/, '');
  @result>>.=subst(:g, /'$('(.*?)')'/, -> $/ { '${'~$0~'}' });
  my %named;
  ## Our nice for loop has been replaced now that we support named
  ## parameters. Oh well, such is life.
  loop (my $i=0; $i < @result.elems; $i++) {
    my $param = @result[$i];
    if $param ~~ /^ ':' (\w+) '(' (.*?) ')' $/ {
      my $key = ~$0;
      my $val = ~$1;
      if $query { $val = self!parse-rules($query, $key, $val); }
      %named{$key} = $val;
      @result.splice($i, 1);
      if $i < @result.elems {
        $i--;
      }
    }
    else {
      if $query { @result[$i] = self!parse-rules($query, $i, $param); }
    }
  }

  my $results = @result.elems - 1;
  my $defs    = @defaults.elems;

  if $results < $defs {
    @result.push: @defaults[$results..$defs-1];
  }
  ## Named params are always last.
  if ($named || (%named.elems > 0)) {
    @result.push: %named;
  }
  return @result;
}

method !parse-rules ($rules, $tag, $value) {
  my $stringy = False;
  if $rules ~~ Hash && ($rules{'.STRING'} :exists) {
    $stringy = True;
  }
  if $rules ~~ Hash && ($rules{$tag}:exists) {
    if $rules{$tag} {
      if $stringy {
        return self.query($value);
      }
      else {
        return self.parse-string($value);
      }
    }
    else {
      return $value;
    }
  }
  else {
    if $stringy {
      return self.parse-string($value);
    }
    else {
      return self.query($value);
    }
  }
}

method parse-string ($string) {
  $string.subst(:g, rx/'${' (.*?) '}'/, -> $/ { self.query($0) });
}

## This handles the lookups for query().
method !lookup (@paths is copy, $data) {
  my $path = @paths.shift;
  my $found;
  given $data {
    when Hash {
      if $data{$path} :exists {
        $found = .{$path};
      }
    }
    when Array {
      if $path < .elems {
        $found = .[$path];
      }
    }
    default {
      my ($command, *@args) = self.get-args(:query({0=>0}), $path);
      if .can($command) {
        $found = ."$command"(|@args);
      }
      else {
          warn "attempt to access an invalid item '$path'.";
      }
    }
  }
  if @paths {
    return self!lookup(@paths, $found);
  }
  return $found;
}

