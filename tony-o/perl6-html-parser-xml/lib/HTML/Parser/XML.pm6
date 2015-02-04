#!/usr/bin/env perl6
use XML;

class HTML::Parser::XML {
  has %!formtags = qw<input 1 option 1 optgroup 1 select 1 button 1 datalist 1 textarea 1>;
  has %!openisclose = %(
    tr       => %(qw<tr 1 th 1 td 1 >),
    th       => %(qw<th 1>),
    td       => %(qw<thead 1 td 1>),
    body     => %(qw<head 1 link 1 script 1>),
    li       => %(qw<li 1>),
    p        => %(qw<p 1>),
    input    => %!formtags,
    option   => %!formtags,
    optgroup => %!formtags,
    select   => %!formtags,
    button   => %!formtags,
    datalist => %!formtags,
    textarea => %!formtags,
    option   => %(qw<option 1>),
    optgroup => %(qw<optgroup 1>),
  );
  has %!specials    = qw<script 1 style 1>;
  has Str           $.html   is rw;
  has Int           $.index  is rw;
  has XML::Document $.xmldoc is rw;
  has Int           %.flags = enum <INSCRIPT INSTYLE>;
  has %!voids       = qw«__proto__ 1 area 1 base 1 basefront 1 br 1 col 1 command 1 embed 1 frame 1 hr 1 img 1 input 1 isindex 1 keygen 1 link 1 meta 1 param 1 source 1 track 1 wbr 1 path 1 circle 1 ellipse 1 line 1 rect 1 use 1»;
  method !ds {
    while $.html.substr($.index, 1) ~~ rx{\s} { 
      $.index++; 
    }
  }


  method parse (Str $html) {
    my enum state «NIL INATTRKEY INATTRVAL»;
    $.index     = 0;
    $.html      = $html;
    my $buffer  = '';
    my $status  = NIL;
    my $cparent = XML::Element.new: name => 'html';
    my $cbuffer = '';
    my $tbuffer = '';
    my $mquote  = '';
    my $bindex  = 0;
    my $qnest   = 0;
    my %attrbuf = Hash.new;
    my @nest    = Array.new;
    my $aclose  = 0;
    $.xmldoc = XML::Document.new: root => $cparent; 
    @nest.push: $.xmldoc.root;
    while $.index < $.html.chars {
      $cbuffer = $.html.substr($.index, 1);
      if $cbuffer eq '<' {
        #build tag and attributes
        if $.html.substr($.index + 1, 1) ne ' ' {
          my $tag  = my $id = my $buffer = '';
          my %attr = Hash.new;
          $cbuffer = $.html.substr(++$.index, 1);
          $aclose  = 0;
          #gather the tag
          while $cbuffer !~~ rx{ [ \s | '>' ] } {
            $tag     ~= $cbuffer;
            $cbuffer  = $.html.substr(++$.index, 1);
          }
          $tag = lc $tag;
          #gather the attributes
          self!ds if $cbuffer !~~ rx{ [ '>' | '/' ] };
          $cbuffer = $.html.substr($.index, 1);
          $qnest = 0;
          if $tag.substr(0,3) eq '!--' {
            while $.html.substr($.index, 3) ne '-->' {
              $buffer ~= $.html.substr($.index,1);
              $.index++;
            }
            $.index += 3;
          } elsif $tag eq "!doctype" {
            while $.html.substr($.index, 1) ne '>' {
              $buffer ~= $.html.substr($.index,1);
              $.index++;
            }
            $.index += 1;
          } else {
            while $cbuffer !~~ rx{ [ '>' | '/' ] } || $qnest == 1 {
              $buffer ~= $cbuffer;
              $cbuffer = $.html.substr(++$.index, 1);
              $mquote  = $cbuffer if $cbuffer ~~ rx{ [ '"' | '\'' ] } && $qnest == 0;
              $qnest   = 1, next  if $cbuffer ~~ rx{ [ '"' | '\'' ] } && $qnest == 0;
              $qnest   = 0        if $cbuffer eq $mquote && $qnest == 1;
            }
            $.index++;
            { $aclose = 1; ++$.index; $cbuffer = $.html.substr($.index, 1); } if $cbuffer eq '/';
          }
          #parse attribute string;
          $bindex  = 0;
          %attrbuf = key => '', value => '';
          %attr<text> = $buffer if $tag eq '!--';
          if $tag.substr(0,3) ne '!--' {
            while $bindex < $buffer.chars {
              $cbuffer = $buffer.substr($bindex++, 1);
              if ( $cbuffer ~~ rx{ \s } && ( ( $status eq INATTRVAL && $mquote eq '' ) || $status eq INATTRKEY ) ) || ( $cbuffer eq $mquote && $status eq INATTRVAL ) {
                if $status ne NIL {
                  %attr{%attrbuf<key>} = %attrbuf eq '' ?? Nil !! %attrbuf<value>;
                }
                %attrbuf = key => '', value => '';
                $status = NIL;
                next;
              }
              #start building a key
              if $cbuffer !~~ rx{ [ '=' | \s ] } && ( $status eq NIL || $status eq INATTRKEY ) {
                %attrbuf<key> ~= $cbuffer;
                $status = INATTRKEY;
              }
              if $status eq INATTRVAL {
                %attrbuf<value> ~= $cbuffer;
              }
              if $cbuffer ~~ rx{ '=' } && $status eq INATTRKEY {
                $mquote = '';
                $mquote = $buffer.substr($bindex++, 1) if $buffer.substr($bindex, 1) ~~ rx{ [ '"' | '\'' ] };
                $status = INATTRVAL;
              }
            }
            %attr{%attrbuf<key>} = %attrbuf<value> if %attrbuf<key> ne '';
          }
          
          #fast forward over specials
          if %!specials{$tag}.defined && %!specials{$tag} eq 1 {
            $.index++ while lc($.html.substr($.index, $tag.chars + 3)) ne "</$tag>";
          }
          #handle special cases
          $cbuffer = $.html.substr($.index, 1);

          if $tag.defined && $tag eq '!doctype' {
            try {
              %.xmldoc.root.attribs{%attr.keys} = %attr.values;
            };
          } elsif $tag.defined && $tag eq 'script' {
            @nest.push(XML::Element.new(name => 'script'));
          } else {
            if $tag.substr(0,1) eq '/' || $tag.substr(0,*-1) eq '/' {
              @nest[@nest.elems - 1].append(XML::Text.new(text => $tbuffer)) if $tag ne '!--' && $tbuffer ne '';
              $tbuffer = '';
              @nest.pop if @nest.elems > 1;
              %attr = ();
              $tag  = '';
            } else {
              if $tag eq 'html' && $cparent.elements.elems == 0 {
                #swap for the document's html tag
                my $node = XML::Element.new(attribs => %attr, name => $tag);
                @nest    = $node;
                $cparent = $node;
                $.xmldoc = XML::Document.new: root => $cparent; 
              } else {
                try {
                  if %!openisclose{@nest[@nest.elems - 1].name}.defined {
                    for %!openisclose{@nest[@nest.elems - 1].name}.keys -> $k {
                      if $k eq $tag && @nest[*-1].name eq $tag {
                        @nest[@nest.elems - 1].append(XML::Text.new(text => $tbuffer)) if $tbuffer ne '';
                        $tbuffer = '';
                        @nest.pop if @nest.elems > 1;
                        last; 
                      }
                    }
                  }

                  my $node;
                  $node = XML::Element.new(attribs => %attr, name => $tag) if $tag.substr(0,3) ne '!--';
                  $node = XML::Comment.new(data => %attr<text>) if $tag.substr(0,3) eq '!--';
                  @nest[@nest.elems - 1].append(XML::Text.new(text => $tbuffer)) if $tag.substr(0,3) ne '!--';
                  @nest[@nest.elems - 1].append($node); 
                  @nest.push($node)  if $aclose == 0 && (!%!voids{$tag}.defined || %!voids{$tag} ne 1) && $node !~~ XML::Comment;
                  $tbuffer = '';
                };
              }
            }
            $status = NIL;
          }
        }
      } else {
        $tbuffer ~= $cbuffer;
        $.index++; 
      }
    }
    return $.xmldoc;
  }

};
