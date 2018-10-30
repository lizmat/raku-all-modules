use XML;

use NativeCall;
use Gumbo::Binding;

unit class Gumbo::Parser;

has XML::Document $.xmldoc;
has Duration	$.c-parse-duration;
has Duration	$.xml-creation-duration;
has Int		%.stats;
has Bool	$!nowhitespace = False;

method parse (Str $html, :$nowhitespace = False, *%filters) returns XML::Document {
    $!nowhitespace = $nowhitespace;
    my $t = now;
    if (%filters.elems > 0) {
      die "Gumbo, parse_html : No TAG specified in the filter" unless %filters<TAG>.defined;
      die "Gumbo, parse_html : Filters only allow 3 elements, did you try to filter on more than one attribute?" if %filters.elems > 3;
    }

    my GumboOutput $go = gumbo_parse($html);
    $!c-parse-duration = now - $t;
    $t = now;
    my GumboNode $groot = $go.root;
    my GumboNode $gdoc = $go.document;
    %!stats<xml-objects> = 1;
    %!stats<whitespaces> = 0;
    %!stats<elements> = 1;
    if ($groot.type eq GUMBO_NODE_ELEMENT.value) {
      my $htmlroot = build-element($groot.v.element);
      my $tab_child = nativecast(CArray[Pointer], $groot.v.element.children.data);
      loop (my $i = 0; $i < $groot.v.element.children.length; $i++) {
        #my $n = nativecast(gumbo_node_s, $tab_child[$i]);
	self!build-tree(nativecast(GumboNode, $tab_child[$i]), $htmlroot) if %filters.elems eq 0;
	if %filters.elems > 0 {
	  my $ret = self!build-tree2(nativecast(GumboNode, $tab_child[$i]), $htmlroot, %filters);
	  last unless $ret;
	}
      }
      $!xmldoc = XML::Document.new: root => $htmlroot;
    }
    if ($gdoc.type eq GUMBO_NODE_DOCUMENT.value) {
      my GumboDocument $cgdoc = $gdoc.v.document;
      my $tab_child = nativecast(CArray[Pointer], $cgdoc.children.data);
      loop (my $i = 0; $i < $cgdoc.children.length; $i++) {
	my $node = nativecast(GumboNode, $tab_child[$i]);
	if ($node.type eq GUMBO_NODE_COMMENT.value)
	{
	  #No idea what to do, it probably catch comments outside the html tag
	}
      }
    }
    $!xml-creation-duration = now - $t;
    #say $kGumboDefaultOptions;
    my GumboOptions $gopt := cglobal($GUMBO_LIB, 'kGumboDefaultOptions', GumboOptions);
    gumbo_destroy_output($gopt, $go);
    return $!xmldoc;
  }

  method	!build-tree(GumboNode $node, XML::Element $parent is rw) {
    %!stats<xml-objects>++;
    given $node.type {
      when GUMBO_NODE_ELEMENT.value {
        my $xml = build-element($node.v.element);
        $parent.append($xml);
        %!stats<elements>++;
        my $tab_child = nativecast(CArray[Pointer], $node.v.element.children.data);
	loop (my $i = 0; $i < $node.v.element.children.length; $i++) {
	  self!build-tree(nativecast(GumboNode, $tab_child[$i]), $xml);
	}
	0;
      }
      when GUMBO_NODE_TEXT.value {
        my $xml = XML::Text.new(text => $node.v.text.text);
        $parent.append($xml);
      }
      when GUMBO_NODE_WHITESPACE.value {
	%!stats<whitespaces>++;
	if ! $!nowhitespace {
	  my $xml = XML::Text.new(text => $node.v.text.text);
	  $parent.append($xml);
	} else {
	  %!stats<xml-objects>--;
	}
      }
      when GUMBO_NODE_COMMENT.value {
        my $xml = XML::Comment.new: data => $node.v.text.text;
        $parent.append($xml);
      }
      when GUMBO_NODE_CDATA.value {
        my $xml = XML::CData.new: data => $node.v.text.text;
        $parent.append($xml);
      }
    }
  }
  # Only filter some elements
  method	!build-tree2(GumboNode $node, XML::Element $parent is rw, %filters) returns Bool {
    my $in_filter = False;
    given $node.type {
      when GUMBO_NODE_ELEMENT.value {
        my $xml;
        if (%filters<TAG> eq gumbo_normalized_tagname($node.v.element.tag)) {
          my $elem := $node.v.element;
	  if ($elem.attributes.defined && (%filters.elems > 1 && !%filters<SINGLE>.defined || %filters.elems > 2 && %filters<SINGLE>.defined)) {
	    my $tab_attr = nativecast(CArray[Pointer], $elem.attributes.data);
	    loop (my $i = 0; $i < $elem.attributes.length; $i++) {
	      my $cattr = nativecast(GumboAttribute, $tab_attr[$i]);
	      with %filters{$cattr.name} {
                 my $filter = %filters{$cattr.name};
		 if $filter ~~ Str && $filter eq $cattr.value || $filter ~~ Regex && $cattr.value ~~ $filter {
	           $in_filter = True;
                   last;
                 }
	      }
	    }
	  }
	  #No filtering on attributes
	  if ((%filters.elems eq 1 && !%filters<SINGLE>.defined || 
	       %filters.elems eq 2 && %filters<SINGLE>.defined)) {
	    $in_filter = True;
	  }
	  if ($in_filter) {
	    %!stats<xml-objects>++;
	    %!stats<elements>++;
	    $xml = build-element($node.v.element);
	    $parent.append($xml);
	  }
	}
        my $tab_child = nativecast(CArray[Pointer], $node.v.element.children.data);
	loop (my $i = 0; $i < $node.v.element.children.length; $i++) {
	  my $ret = True;
	  self!build-tree(nativecast(GumboNode, $tab_child[$i]), $xml) if $in_filter;
	  $ret = self!build-tree2(nativecast(GumboNode, $tab_child[$i]), $parent, %filters) if !$in_filter;
	  return False unless $ret;
	}
	return False if $in_filter && %filters<SINGLE>.defined;
      }
     }
     return True;
  }
  
  sub	build-element(GumboElement $elem) {
    my $xml = XML::Element.new;
    $xml.name = gumbo_normalized_tagname($elem.tag);
    return $xml unless $elem.attributes.defined;
    my $tab_attr = nativecast(CArray[Pointer], $elem.attributes.data);
    loop (my $i = 0; $i < $elem.attributes.length; $i++) {
      my $cattr = nativecast(GumboAttribute, $tab_attr[$i]);
      $xml.attribs{$cattr.name} = $cattr.value;
    }
    return $xml;
  }
