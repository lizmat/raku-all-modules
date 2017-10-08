#!/usr/bin/perl6
unit class Dictionary::Create::DSL;
class Article {
	has Str $!content;
	method append-line (Str $innerText) {
		$!content ~= "\n\t$innerText";
	}
	method append (Str $innerText) {
		$!content ~= " $innerText";
	}
	method space (@tags) {
		return @tags.join(" ");
	}
	method give() returns Str {
		return $!content;
	}
	method set-newline {
		$!content ~= "\n";
	}
	method set-title ($title where Str | Int) {
		$!content = $title.WHAT === Str ?? $title !! $title.Str;
	}
	method add-font-tag (Str $tag, Str $innerText, Hash %params?) returns Str {
		if ( ! $tag ~~ /^ [ b || u || i || c ] $/ ) {
			die "Wrong tag was given!";
		}
		my Str $left = not %params ?? "[$tag]" !! "[$tag " ~ %params.fmt("%s=%s", " ") ~ "]";
		return "{$left}{$innerText}[/{$tag}]";
	}
	method mark-secondary (Str $innerText) {
		return "[*]{$innerText}[/*]";
	}
	method m-tag (Int $count, Str $innerText) {
		return "[m{$count.Str}]{$innerText}[/m]";
	}
	method translation (Str $innerText) {
		return "[trn]{$innerText}[/trn]";
	}
	method example (Str $innerText) {
		return "[ex]{$innerText}[/ex]";
	}
	method comment (Str $innerText) {
		return "[com]{$innerText}[/com]";
	}
	method index-exclude (Str $innerText) {
		return "[!trs]{$innerText}[/!trs]";
	}
	method multimedia (Str $path) {
		return "[s]{$path}[/s]";
	}
	method url (Str $url) {
		return "[url]{$url}[/url]";
	}
	method popup (Str $innerText) {
		return "[p]{$innerText}[/p]";
	}
	method accent (Str $innerText) {
		return "[']{$innerText}[/']";
	}
	method language (Hash %properties where $_.elems < 2, Str $innerText) {
		return (
			%properties.elems == 0
			?? "[lang]"
			!! "[lang {%properties.fmt('%s="%s"')}]"
		) ~ "{$innerText}[/lang]";
	}
	method reference (Str $innerText) {
		return "[ref]{$innerText}[/ref]";
	}

}
# vim: ft=perl6
