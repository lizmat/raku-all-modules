class Flower;

use XML;

has $.provider handles <fetch store>;

submethod BUILD (:$provider)
{
  if $provider
  {
    $!provider = $provider;
  }
  else
  {
    require Flower::Provider::File;
    $!provider = ::('Flower::Provider::File').new;
  }
}

## Data, is used to store the replacement data. Is available for modifiers.
has %.data is rw;

## Default stores the elements in order of parsing.
## Used to get the 'default' value, and other such stuff.
has @.elements;

## The XML application languages we support.
has @.plugins;

## Add an XML application language plugin.
method add-plugin ($plugin) {
  my $object = self!get-plugin($plugin);
  if $object.defined {
    @.plugins.push: $object;
  }
}

## Add an XML application language plugin, to the beginning of our list.
method insert-plugin ($plugin) {
  my $object = self!get-plugin($plugin);
  if $object.defined {
    @.plugins.unshift: $object;
  }
}

## Return an object instance representing a plugin.
## Can take an object instance or a type object.
method !get-plugin ($plugin) {
  my $object = $plugin;
  if ! $plugin.defined {
    $object = $plugin.new(:flower(self));
    if $object.can('init') {
      $object.init();
    }
  }
  return $object;
}

## The main method to parse a template. Expects an XML::Document.
multi method parse (XML::Document $template, *%data) {
  ## First we need to set the data, for later re-use.
  %.data = %data;

  ## Let's see if the namespaces has been renamed.
  for @.plugins -> $plugin {
    $plugin.custom-tag = $template.root.nsPrefix($plugin.ns);
  }

  ## Okay, now let's parse the elements.
  self.parse-element($template.root, :safe);
  return $template;
}

## Parse a template in XML::Element form.
multi method parse (XML::Element $template, *%data) {
  my $document = XML::Document.new($template);
  return self.parse($document, |%data);
}

## Parse a template that is passed as XML text.
multi method parse (Stringy $template, *%data) {
  my $document = XML::Document.new($template);
  if ($document) {
    return self.parse($document, |%data);
  }
}

## Process a template using our Provider class.
method process ($name, *%data) {
  my $file = self.fetch($name);
  if $file {
    my $template = XML::Document.load($file);
    if $template {
      return self.parse($template, |%data);
    }
  }
}

## parse-elements: Parse the child elements of an XML node.
method parse-elements ($xml is rw, $custom-parser?) {
  ## Due to the strange nature of some rules, we're not using the
  ## 'elements' helper, nor using a nice 'for' loop. Instead we're doing this
  ## by hand. Don't worry, it'll all make sense.
  loop (my $i=0; True; $i++) {
    if $i == $xml.nodes.elems { last; }
    my $element = $xml.nodes[$i];
    if $element !~~ XML::Element { next; } # skip non-elements.
    @.elements.unshift: $element; ## Stuff the newest element into place.
    if ($custom-parser) {
      $custom-parser($element, $custom-parser);
    }
    else {
      self.parse-element($element);
    }
    @.elements.shift; ## and remove it again.
    ## Now we clean up removed elements, and insert replacements.
    if ! defined $element {
      $xml.nodes.splice($i--, 1);
    }
    elsif $element ~~ Array {
      $xml.nodes.splice($i--, 1, |@($element));
    }
    else {
      $xml.nodes[$i] = $element; # Ensure the node is updated.
    }
  }
}

## parse-element: parse a single element.
method parse-element($element is rw, :$safe) {
  ## Let's do this.
  for @.plugins -> $plugin {
    ## First attributes.
    my $defel = False; ## By default we handle XML Attributes, not Elements.
    if $plugin.options<element> :exists {
      $defel = $plugin.options<element>;
    }
    for $plugin.handlers -> $hand {
      my $name;            ## Name of the attribute or element.
      my $meth;            ## Method to call.
      my $issafe = False;  ## Is it safe? Only used if safe mode is in place.
      my $isel = $defel;   ## Is this an element instead of an attribute?
      if $hand ~~ Pair {
        $name  = $hand.key;
        my $rules = $hand.value;
        if $rules ~~ Hash {
          if $rules<method> :exists {
            $meth = $rules<method>;
          }
          if $rules<safe> :exists {
            $issafe = $rules<safe>;
          }
          if $rules<element> :exists {
            $isel = $rules<element>;
          }
        }
        elsif $rules ~~ Str {
          ## If the pair value is a string, it's the method name.
          $meth = $rules; 
        }
      }
      elsif $hand ~~ Str {
        ## If the handler is a string, it's the name of the attribute/element.
        $name = $hand;
      }
      if ! $meth {
        ## If no method has been found by other means, the default is
        ## parse-$name(). E.g. for a name of 'block', we'd call parse-block().
        $meth = "parse-$name";
      }
      if $safe && !$issafe {
        next; ## Skip unsafe handlers.
      }
      if ! $meth { next; } ## Undefined method, we can't handle that.
      my $fullname = $plugin.tag ~ ':' ~ $name;
#      $*ERR.say: "-- Parsing $fullname tags";
      if $isel {
        if $element.name eq $fullname {
          $plugin."$meth"($element, $fullname);
        }
      }
      else {
        if $element.attribs{$fullname} :exists {
          $plugin."$meth"($element, $fullname);
        }
      }
      if $element !~~ XML::Element { last; } ## skip if we changed type.
    } ## /for $plugin.handlers
  } ## /for @.plugins

  ## Okay, now we parse child elements.
  if $element ~~ XML::Element {
    self.parse-elements($element);
  }
}

