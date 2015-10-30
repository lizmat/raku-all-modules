# This project is under the same licence as Rakudo
use v6;

use NativeCall;
use XML;


module Gumbo {

  our $gumbo_last_c_parse_duration is export;
  our $gumbo_last_xml_creation_duration is export;

  class gumbo_node_t is repr('CPointer') {};
  class gumbo_output_t is repr('CPointer') {};
  class gumbo_attribute_t is repr('CPointer') {};
  
#   class HTML::Parser::XML is export {
#     has	XML::Document	$.xmldoc;
#     has			$.html;
#     has			$.isgumbo = True;
#     
#     method parse (Str $html) {
#       $.html = $html;
#       $.xmldoc = parse-html($html);
#       say "gumbo parseur";
#       return $.xmldoc;
#     }
#   }
#   
  enum gumbo_node_type (
     GUMBO_NODE_DOCUMENT => 0,
     GUMBO_NODE_ELEMENT => 1,
     GUMBO_NODE_TEXT => 2,
     GUMBO_NODE_CDATA => 3,
     GUMBO_NODE_COMMENT => 4,
     GUMBO_NODE_WHITESPACE => 5,
     GUMBO_NODE_TEMPLATE => 6
  );
  
#   typedef struct {
#    68   unsigned int line;
#    69   unsigned int column;
#    70   unsigned int offset;
#    71 } GumboSourcePosition;

  class gumbo_source_position is repr('CStruct') {
    has uint32	$.line;
    has uint32	$.column;
    has uint32	$.offset;
  }
#   typedef struct {
#    90   const char* data;
#    91 
#    93   size_t length;
#    94 } GumboStringPiece;
#   
  class gumbo_string_piece_s is repr('CStruct') {
    has Str		$.data;
    has uint32		$.length;
  }
  
  #    typedef struct {
#      void** data;
#    
#      unsigned int length;
#    
#      unsigned int capacity;
#    } GumboVector;
  
  class gumbo_vector_s is repr('CStruct') {
    has OpaquePointer $.data;
    has uint32        $.length;
    has uint32	      $.capacity; 
  }
  
    #typedef struct {
  #   GumboVector /* GumboNode* */ children;
  # 
  #   // True if there was an explicit doctype token as opposed to it being omitted.
#      bool has_doctype;
#    
#      // Fields from the doctype token, copied verbatim.
#      const char* name;
#      const char* public_identifier;
#      const char* system_identifier;
#    
#      GumboQuirksModeEnum doc_type_quirks_mode;
#    } GumboDocument;
#   
  class gumbo_document_s is repr('CStruct') {
     HAS gumbo_vector_s $.children;
     has int8		$.has_doctype;
     has Str		$.name;
     has Str		$.public_identifier;
     has Str		$.system_identifier;
     has int32		$.doc_type_quirks_mode;
  }

  
#   typedef struct {
#   231   GumboAttributeNamespaceEnum attr_namespace;
#   232 
#   237   const char* name;
#   238 
#   243   GumboStringPiece original_name;
#   244 
#   251   const char* value;
#   252 
#   261   GumboStringPiece original_value;
#   262 
#   264   GumboSourcePosition name_start;
#   265 
#   271   GumboSourcePosition name_end;
#   272 
#   274   GumboSourcePosition value_start;
#   275 
#   277   GumboSourcePosition value_end;
#   278 } GumboAttribute;
#   279 
#   
  class gumbo_attribute_s is repr('CStruct') {
    has	int32			$.attr_namespace;
    has Str			$.name;
    HAS gumbo_string_piece_s	$.original_name;
    has Str			$.value;
    HAS gumbo_string_piece_s	$.original_value;
    HAS gumbo_source_position	$.name_start;
    HAS gumbo_source_position	$.name_end;
    HAS gumbo_source_position	$.value_start;
    HAS gumbo_source_position	$.value_end;
  }

#   typedef struct {
#   453   const char* text;
#   454 
#   459   GumboStringPiece original_text;
#   460 
#   465   GumboSourcePosition start_pos;
#   466 } GumboText;

    class gumbo_text_s is repr('CStruct') {
      has Str			$.text;
      HAS gumbo_string_piece_s	$.original_text;
      HAS gumbo_source_position	$.start_pos;
    }
    
#      typedef struct {
#   477   GumboVector /* GumboNode* */ children;
#   478 
#   480   GumboTag tag;
#   481 
#   483   GumboNamespaceEnum tag_namespace;
#   484 
#   491   GumboStringPiece original_tag;
#   492 
#   498   GumboStringPiece original_end_tag;
#   499 
#   501   GumboSourcePosition start_pos;
#   502 
#   504   GumboSourcePosition end_pos;
#   505 
#   510   GumboVector /* GumboAttribute* */ attributes;
#   511 } GumboElement;

  class gumbo_element_s is repr('CStruct') {
    HAS gumbo_vector_s		$.children;
    has int32			$.tag;
    has int32			$.tag_namespace;
    HAS gumbo_string_piece_s	$.original_tag;
    HAS gumbo_string_piece_s	$.original_end_tag;
    HAS gumbo_source_position	$.start_pos;
    HAS gumbo_source_position	$.end_pos;
    HAS gumbo_vector_s		$.attributes;
  }
  
#   struct GumboInternalNode {
#     GumboNodeType type;
#   
#     GumboNode* parent;
#   
#      size_t index_within_parent;
#    
#     GumboParseFlags parse_flags;
#    
#      union {
#        GumboDocument document;  // For GUMBO_NODE_DOCUMENT.
#        GumboElement element;    // For GUMBO_NODE_ELEMENT.
#        GumboText text;          // For everything else.
#      } v;
#    };
  class g_node_union is repr('CUnion') {
    HAS gumbo_document_s	$.document;
    HAS gumbo_element_s 	$.element;
    HAS gumbo_text_s		$.text;
  }
  
  class gumbo_node_s is repr('CStruct') {
    has int32		$.type;
    has gumbo_node_s	$.parent;
    has uint32		$.index_within_parent;
    has int32		$.parse_flags;
    HAS g_node_union	$.v;
  }
  
  class gumbo_vector_t is repr('CPointer') {};
  


  
#   typedef struct GumboInternalOutput {
#      GumboNode* document;
#    
#      GumboNode* root;
#    
#      GumboVector /* GumboError */ errors;
#    } GumboOutput;
#   
  class gumbo_output_s is repr('CStruct') {
    has gumbo_node_t $.document;
    has gumbo_node_t $.root;
    HAS gumbo_vector_s $.errors;
  }
  

  sub gumbo_parse(Str) is native('libgumbo') returns gumbo_output_t { * }
  sub gumbo_normalized_tagname(int32) is native('libgumbo') returns str { * }
  
  #this is only for debug purpose, show the size of the differents struct
  sub gumbo-type-size {
    for gumbo_output_s, gumbo_vector_s, gumbo_attribute_s, gumbo_document_s, gumbo_element_s, gumbo_node_s, gumbo_source_position, gumbo_string_piece_s, gumbo_text_s -> $type {
      say $type.perl~" : "~nativesizeof($type);
    }
    say nativesizeof(int32);
  }
  
  sub parse-html (Str $html, *%filters) is export {
    my $xmldoc;
    #gumbo-type-size();
    #explicitly-manage($html);
    my $t = now;
    
    if (%filters.elems > 0) {
      die "Gumbo, parse_html : No TAG specified in the filter" unless %filters<TAG>.defined;
      die "Gumbo, parse_html : Filters only allow 3 elements, did you try to filter on more than one attribute?" if %filters.elems > 3;
    }
    
    my gumbo_output_t $gumbo_output = gumbo_parse($html);
    $gumbo_last_c_parse_duration = now - $t;
    $t = now;
    my gumbo_output_s $go = nativecast(gumbo_output_s, $gumbo_output);
    my gumbo_node_s $groot = nativecast(gumbo_node_s, $go.root);
    my gumbo_node_s $gdoc = nativecast(gumbo_node_s, $go.document);
    if ($groot.type eq GUMBO_NODE_ELEMENT.value) {
      my $htmlroot = build-element($groot.v.element);
      my $tab_child = nativecast(CArray[gumbo_node_t], $groot.v.element.children.data);
      loop (my $i = 0; $i < $groot.v.element.children.length; $i++) {
	build-tree(nativecast(gumbo_node_s, $tab_child[$i]), $htmlroot) if %filters.elems eq 0;
	if %filters.elems > 0 {
	  my $ret = build-tree2(nativecast(gumbo_node_s, $tab_child[$i]), $htmlroot, %filters);
	  last unless $ret;
	}
      }
      $xmldoc = XML::Document.new: root => $htmlroot;
    }
    if ($gdoc.type eq GUMBO_NODE_DOCUMENT.value) {
      my gumbo_document_s $cgdoc = $gdoc.v.document;
      my $tab_child = nativecast(CArray[gumbo_node_t], $cgdoc.children.data);
      loop (my $i = 0; $i < $cgdoc.children.length; $i++) {
	my $node = nativecast(gumbo_node_s, $tab_child[$i]);
	if ($node.type eq GUMBO_NODE_COMMENT.value)
	{
	  #No idea what to do, it probably catch comments outside the html tag
	}
      }
    }
    $gumbo_last_xml_creation_duration = now - $t;
    return $xmldoc;
  }

  sub	build-tree(gumbo_node_s $node, XML::Element $parent is rw) {
    given $node.type {
      when GUMBO_NODE_ELEMENT.value {
        my $xml = build-element($node.v.element);
        $parent.append($xml);
        my $tab_child = nativecast(CArray[gumbo_node_t], $node.v.element.children.data);
	loop (my $i = 0; $i < $node.v.element.children.length; $i++) {
	  build-tree(nativecast(gumbo_node_s, $tab_child[$i]), $xml);
	}
      }
      when GUMBO_NODE_TEXT.value | GUMBO_NODE_WHITESPACE.value {
        my $xml = XML::Text.new(text => $node.v.text.text);
        $parent.append($xml);
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
  sub	build-tree2(gumbo_node_s $node, XML::Element $parent is rw, %filters) returns Bool {
    my $in_filter = False;
    given $node.type {
      when GUMBO_NODE_ELEMENT.value {
        my $xml;
        if (%filters<TAG> eq gumbo_normalized_tagname($node.v.element.tag)) {
          my $elem := $node.v.element;
	  if ($elem.attributes.defined && (%filters.elems > 1 && !%filters<SINGLE>.defined || %filters.elems > 2 && %filters<SINGLE>.defined)) {
	    my $tab_attr = nativecast(CArray[gumbo_attribute_t], $elem.attributes.data);
	    loop (my $i = 0; $i < $elem.attributes.length; $i++) {
	      my $cattr = nativecast(gumbo_attribute_s, $tab_attr[$i]);
	      {$in_filter = True; last } if (%filters{$cattr.name}.defined && %filters{$cattr.name} eq $cattr.value);
	    }
	  }
	  #No filtering on attributes
	  if ((%filters.elems eq 1 && !%filters<SINGLE>.defined || 
	       %filters.elems eq 2 && %filters<SINGLE>.defined)) {
	    $in_filter = True;
	  }
	  if ($in_filter) {
	    $xml = build-element($node.v.element);
	    $parent.append($xml);
	  }
	}
        my $tab_child = nativecast(CArray[gumbo_node_t], $node.v.element.children.data);
	loop (my $i = 0; $i < $node.v.element.children.length; $i++) {
	  my $ret = True;
	  build-tree(nativecast(gumbo_node_s, $tab_child[$i]), $xml) if $in_filter;
	  $ret = build-tree2(nativecast(gumbo_node_s, $tab_child[$i]), $parent, %filters) if !$in_filter;
	  return False unless $ret;
	}
	return False if $in_filter && %filters<SINGLE>.defined;
      }
     }
     return True;
  }
  
  sub build-element(gumbo_element_s $elem) {
    my $xml = XML::Element.new;
    $xml.name = gumbo_normalized_tagname($elem.tag);
    return $xml unless $elem.attributes.defined;
    my $tab_attr = nativecast(CArray[gumbo_attribute_t], $elem.attributes.data);
    loop (my $i = 0; $i < $elem.attributes.length; $i++) {
      my $cattr = nativecast(gumbo_attribute_s, $tab_attr[$i]);
      $xml.attribs{$cattr.name} = $cattr.value;
    }
    return $xml;
  }
 

}
