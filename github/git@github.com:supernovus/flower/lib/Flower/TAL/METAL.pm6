use Flower::Lang;
unit class Flower::TAL::METAL does Flower::Lang; 

## The METAL XML Application Language.

use XML;

has $.default-tag = 'metal';
has $.ns = 'http://xml.zope.org/namespaces/metal';

## The tags for METAL macro processing.
## -- define-slot and use-slot are handled by parse_use().
has @.handlers =
  'define-macro' => 'parse-define',
  'use-macro'    => 'parse-use';

## The cache for METAL macros.
has %.metal is rw;

## The cache for included XML templates.
has %.file is rw;

## Loading more XML documents.
## Now caches results, for easy re-use.
method load-xml-file ($filename) {
  if %.file{$filename}:exists {
    return %.file{$filename};
  }

  my $xmltext = $.flower.fetch($filename);
  if $xmltext {
    my $xml = XML::Document.new($xmltext);
    %.file{$filename} = $xml;
    return $xml;
  }
}

## Now the handlers.

method parse-define ($xml is rw, $tag) {
  my $macro = $xml.attribs{$tag};
  $xml.unset: $tag;
  my $section = $xml.cloneNode;
  %!metal{$macro} = $section;
  #say "## Saved macro '$macro': $section";
}

method parse-use ($xml is rw, $tag) {
  my $macro = $xml.attribs{$tag};
  my $fillslot = $.tag~':fill-slot';
  my %params =%( {
    :RECURSE(10),
    $fillslot => True,
  });
  my @slots = $xml.elements(|%params);
  my $found = False;
  if %!metal{$macro}:exists {
    $xml = %!metal{$macro}.cloneNode;
    $found = True;
  }
  else {
    my @ns = $macro.split('#', 2);
    my $file = @ns[0];
    my $section = @ns[1];
    my $include = self.load-xml-file($file);
    if ($include) {
      my $defmacro = $.tag~':define-macro';
      my %search =%( {
        :RECURSE(10),
        $defmacro => $section,
      });
      my @macros = $include.root.elements(|%search);
      if (@macros.elems > 0) {
        $xml = @macros[0].cloneNode;
        $xml.unset: $defmacro;
        %!metal{$macro} = $xml.cloneNode;
        $found = True;
      }
    }
  }
  if ($found) {
    my $metal = self;
    my $parser = -> $element is rw, $me {
      $metal.use-macro-slots(@slots, $element, $me);
    };
    $.flower.parse-elements($xml, $parser);
  }
  else {
    $xml.unset: $tag;
    for @slots -> $slot {
      $slot.unset: $fillslot;
    }
  }
}

method use-macro-slots (@slots, $xml is rw, $parser) {
  my $defslot  = $.tag~':define-slot';
  my $fillslot = $.tag~':fill-slot';
  if $xml.attribs{$defslot}:exists {
    my $slotid = $xml.attribs{$defslot};
    $xml.unset: $defslot;
    for @slots -> $slot {
      if $slot.attribs{$fillslot} eq $slotid {
        $xml = $slot.cloneNode;
        $xml.unset: $fillslot;
        last;
      }
    }
  }
  ## Now let's parse any child elements.
  if $xml ~~ XML::Element {
    $.flower.parse-elements($xml, $parser);
  }
}

