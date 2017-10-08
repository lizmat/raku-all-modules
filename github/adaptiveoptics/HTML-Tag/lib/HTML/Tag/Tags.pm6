use v6;
use HTML::Tag;

class HTML::Tag::a        is HTML::Tag::Link-tag does HTML::Tag::generic-tag['a'] {}
class HTML::Tag::br       is HTML::Tag           does HTML::Tag::generic-single-tag['br'] {}
class HTML::Tag::body     is HTML::Tag           does HTML::Tag::generic-tag['body'] {}
class HTML::Tag::div      is HTML::Tag           does HTML::Tag::generic-tag['div'] {}
class HTML::Tag::fieldset is HTML::Tag::Form-tag does HTML::Tag::generic-tag['fieldset'] {}
class HTML::Tag::form     is HTML::Tag::Form-tag does HTML::Tag::generic-tag['form']
{
    has     $.action is rw;
    has Str $.method is rw = 'POST';

    method do-assignments() {
	callsame;
	$.attr<action> = $.action if $.action;
	$.attr<method> = $.method if $.method;
   }	
}
class HTML::Tag::h1   is HTML::Tag does HTML::Tag::generic-tag['h1'] {}
class HTML::Tag::h2   is HTML::Tag does HTML::Tag::generic-tag['h2'] {}
class HTML::Tag::h3   is HTML::Tag does HTML::Tag::generic-tag['h3'] {}
class HTML::Tag::h4   is HTML::Tag does HTML::Tag::generic-tag['h4'] {}
class HTML::Tag::h5   is HTML::Tag does HTML::Tag::generic-tag['h5'] {}
class HTML::Tag::h6   is HTML::Tag does HTML::Tag::generic-tag['h6'] {}
class HTML::Tag::head is HTML::Tag does HTML::Tag::generic-tag['head'] {}
class HTML::Tag::html is HTML::Tag does HTML::Tag::generic-tag['html'] {}
class HTML::Tag::hr   is HTML::Tag does HTML::Tag::generic-single-tag['hr'] {}
class HTML::Tag::img  is HTML::Tag does HTML::Tag::generic-single-tag['img']
{
    has Str $.src    is rw is required;
    has     $.alt    is rw;
    has Int $.width  is rw;
    has Int $.height is rw;
    has Int $.border is rw;

    method do-assignments() {
	callsame;
	$.attr<src>    = $.src    if  $.src;
	$.attr<alt>    = $.alt    if  $.alt;
	$.attr<width>  = $.width  if  $.width.defined;
	$.attr<height> = $.height if  $.height.defined;
	$.attr<border> = $.border if  $.border.defined;
    }
}
class HTML::Tag::input is HTML::Tag::Form-tag does HTML::Tag::generic-single-tag['input']
{
    has Str  $.type    is rw = 'text';
    has Int  $.min     is rw;
    has Int  $.max     is rw;
    has      $.alt     is rw;
    has      $.checked is rw;

    method do-assignments() {
	callsame;
	$.attr<type>    = $.type    if $.type;
	$.attr<checked> = $.checked if $.checked;
	$.attr<min>     = $.min     if $.min.defined;
	$.attr<max>     = $.max     if $.max.defined;
	$.attr<alt>     = $.alt     if $.alt.defined;
    }
}
class HTML::Tag::label is HTML::Tag does HTML::Tag::generic-tag['label']
{
    has $.for is rw;

    method do-assignments() {
	callsame;
	$.attr<for> = $.for if $.for;
    }
}
class HTML::Tag::legend   is HTML::Tag::Form-tag  does HTML::Tag::generic-tag['legend'] {}
class HTML::Tag::li       is HTML::Tag            does HTML::Tag::generic-tag['li'] {}
class HTML::Tag::link     is HTML::Tag::Link-tag  does HTML::Tag::generic-single-tag['link'] {}
class HTML::Tag::ol       is HTML::Tag            does HTML::Tag::generic-tag['ol']
{
    has $.type is rw;

    method do-assignments() {
	callsame;
	$.attr<type> = $.type if $.type.defined;
    }
}
class HTML::Tag::p        is HTML::Tag            does HTML::Tag::generic-tag['p'] {}
class HTML::Tag::span     is HTML::Tag            does HTML::Tag::generic-tag['span'] {}
class HTML::Tag::table    is HTML::Tag            does HTML::Tag::generic-tag['table'] {}
class HTML::Tag::td       is HTML::Tag::Table-tag does HTML::Tag::generic-tag['td'] {}
class HTML::Tag::th       is HTML::Tag::Table-tag does HTML::Tag::generic-tag['th'] {}
class HTML::Tag::tr       is HTML::Tag            does HTML::Tag::generic-tag['tr'] {}
class HTML::Tag::textarea is HTML::Tag::Form-tag  does HTML::Tag::generic-tag['textarea']
{
    has Int $.rows is rw;
    has Int $.cols is rw;

    method do-assignments() {
	callsame;
	$.attr<rows> = $.rows if $.rows.defined;
	$.attr<cols> = $.cols if $.cols.defined;
    }
}
class HTML::Tag::title is HTML::Tag does HTML::Tag::generic-tag['title'] {}
class HTML::Tag::ul    is HTML::Tag does HTML::Tag::generic-tag['ul'] {}


=begin pod

=head1 AUTHOR

Mark Rushing mark@orbislumen.net

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod

