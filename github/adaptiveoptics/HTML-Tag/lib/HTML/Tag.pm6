use v6;
use HTML::Entity;

class HTML::Tag
{
    has Hash $.attr  is rw = {};
    has      $.id    is rw;
    has      $.class is rw;
    has      $.style is rw;
    has      $.name  is rw;
    
    method mktag(:$prefix, :$suffix = '>') {
	my $tag;
	$tag = $prefix if $prefix;
	$.attr.keys.map: { when 'checked'   { $tag ~= ' checked' }
			   when 'disabled'  { $tag ~= ' disabled' }
			   when 'readonly'  { $tag ~= ' readonly' }
			   when 'required'  { $tag ~= ' required' }
			   when 'autofocus' { $tag ~= ' autofocus' }
			   when 'value'     { $tag ~= " $_=\"{encode-entities($.attr{$_})}\"" } 
			   default          { $tag ~= " $_=\"{$.attr{$_}}\"" };
			 }
	$tag ~= $suffix if $suffix;
	return $tag;
    }

    method do-assignments() {
	$.attr<id>    = $!id    if $!id;
	$.attr<class> = $!class if $!class;
	$.attr<style> = $!style if $!style;
	$.attr<name>  = $!name  if $!name;
    }
}

class HTML::Tag::Link-tag is HTML::Tag
{
    has $.href is rw;
    has $.target is rw;
    has $.rel is rw;
    has $.type is rw;

    method do-assignments() {
	callsame;
	$.attr<href>   = $.href   if $.href;
	$.attr<target> = $.target if $.target;
	$.attr<rel>    = $.rel    if $.rel;
	$.attr<type>   = $.type   if $.type;
    }
}

class HTML::Tag::Table-tag is HTML::Tag
{
    has Int $.colspan is rw;

    method do-assignments() {
	callsame;
	$.attr<colspan> = $.colspan if $.colspan.defined;
    }
}

class HTML::Tag::Form-tag is HTML::Tag
{
    has     $.disabled  is rw;
    has     $.readonly  is rw;
    has     $.required  is rw;
    has     $.autofocus is rw;
    has Int $.maxlength is rw;
    has Int $.size      is rw;
    has     $.value     is rw;
    has     $.form      is rw;

    method do-assignments() {
	callsame;
	$.attr<disabled>  = $.disabled  if $.disabled;
	$.attr<readonly>  = $.readonly  if $.readonly;
	$.attr<required>  = $.required  if $.required;
	$.attr<autofocus> = $.autofocus if $.autofocus;
	$.attr<maxlength> = $.maxlength if $.maxlength.defined;
	$.attr<size>      = $.size      if $.size.defined;
	$.attr<value>     = $.value     if $.value;
	$.attr<form>      = $.form      if $.form;
    }
}   

role HTML::Tag::generic-single-tag[$T]
{
    method render() {
	self.do-assignments;
	my $tag = self.mktag(:prefix("<$T"));
	return $tag;
    }
}

role HTML::Tag::generic-tag[$T]
{
    has @.text is rw = '';

    method render() {
	self.do-assignments;
	my $tag = self.mktag(:prefix("<$T"));
	@.text.map: { next unless $_;
		      $tag ~= $_.^name ~~ /HTML\:\:Tag/ ??
			      $_.render !!
                              encode-entities($_)
		    };
	return $tag ~ "</$T>";
    }
}

=begin pod

=head1 AUTHOR

Mark Rushing mark@orbislumen.net

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
