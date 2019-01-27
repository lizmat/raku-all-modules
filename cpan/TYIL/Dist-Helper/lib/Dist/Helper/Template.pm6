#! /usr/bin/env false

use v6.c;

use Template::Mustache;

unit module Dist::Helper::Template;

multi sub template (
	Str:D $template,
	:%context,
	--> Str
) is export {
	my Str $absolute = "templates/$template";
	my Distribution::Resource $resource = %?RESOURCES{$absolute};

	X::AdHoc.new(payload => "Resource '$absolute' does not exist").throw unless %?RESOURCES{$absolute};

	Template::Mustache.render($resource.slurp, %context);
}

multi sub template (
	Str:D $template,
	IO::Path:D $destination,
	:%context,
	Bool:D :$clobber = False
) is export {
	X::AdHoc.new(payload => "$destination already exists").throw if $destination.IO.e && !$clobber;

	mkdir $destination.parent.absolute;
	spurt($destination, template($template, :%context));
}

multi sub template (
	Str:D $template,
	Str:D $destination,
	:%context,
	Bool:D :$clobber = False
) is export {
	template($template, $destination.IO, :%context, :$clobber);
}
