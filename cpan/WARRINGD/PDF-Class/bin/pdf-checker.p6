#!/usr/bin/env perl6
use v6;

use PDF::Class;
use PDF::Content;
use PDF::Annot;
use PDF::Writer;

my UInt $*max-depth;
my Bool $*contents;
my Bool $*trace;
my Bool $*strict = False;
my PDF::Writer $*writer .= new;
my Str @*exclude;
my %seen{Any};

#| check a PDF against PDF class definitions
sub MAIN(Str $infile,               #| input PDF
         Str  :$password = '',      #| password for the input PDF, if encrypted
         Bool :$*trace,             #| show progress
         Bool :$*contents,          #| validate/check contents of pages, etc         
         Bool :$*strict,            #| perform additional checks
         UInt :$*max-depth = 100,   #| maximum recursion depth
	 Str  :$exclude,            #| excluded entries: Entry1,Entry2
         ) {

    my $doc = PDF::Class.open( $infile, :$password );
    @*exclude = $exclude.split(/:s ',' /)
    	      if $exclude;
    check( $doc, :ent<xref> );
}

|# Recursively check a dictionary (array) object
multi sub check(Hash $obj, UInt :$depth is copy = 0, Str :$ent = '') {
    return if %seen{$obj}++;
    my $ref = $obj.obj-num
	?? "{$obj.obj-num} {$obj.gen-num//0} R "
        !! $*writer.write($obj.content).subst(/\s+/, ' ', :g);
    $*ERR.say: (" " x ($depth*2)) ~ "$ent\:\t" ~ $ref
	if $*trace;
    die "maximum depth of $*max-depth exceeded"
	if ++$depth > $*max-depth;
    my Hash $entries = $obj.entries;
    my Str @unknown-entries;

    check-contents($obj, :$ref)
	if $*contents && $obj.does(PDF::Content);

    for $obj.keys.sort {

        # Avoid following /P back to page then back here via page /Annots
        next if $_ eq 'P' && $obj.isa(PDF::Annot);
	next if @*exclude.grep: $_;

	my $kid;

	do {
	    $kid = $entries{$_}:exists
		?? $obj."$_"()   # entry has an accessor. use it
		!! $obj{$_};     # dereferece hash entry

	    CATCH {
		default {
		    $*ERR.say: "error in $ref$ent entry: $_"; 
		}
	    }
	}

	check($kid, :ent("/$_"), :$depth) if $kid ~~ Array | Hash;

	@unknown-entries.push: '/' ~ $_
	    if $*strict && +$entries && !($entries{$_}:exists);
    }

    $*ERR.say: "unknown entries in $ref{$obj.WHAT} struct: @unknown-entries[]"
	if @unknown-entries && $obj.WHAT.gist ~~ /'PDF::' .*? '::Type'/; 
}

#| Recursively check an array object
multi sub check(Array $obj, UInt :$depth is copy = 0, Str :$ent = '') {
    return if %seen{$obj}++;
    my $ref = $obj.obj-num
	?? "{$obj.obj-num} {$obj.gen-num//0} R "
        !! $*writer.write($obj.content).subst(/\s+/, ' ', :g);
    $*ERR.say: (" " x ($depth*2)) ~ "$ent\:\t" ~ $ref
	if $*trace;
    die "maximum depth of $*max-depth exceeded"
	if ++$depth > $*max-depth;
    my Array $index = $obj.index;
    for $obj.keys.sort {
	my Str $accessor = $index[$_].tied.accessor-name
	    if $index[$_]:exists;
	my $kid;
	do {
	    $kid = $accessor
		?? $obj."$accessor"()  # array element has an accessor. use it
		!! $obj[$_];           # dereference array element

	    CATCH {
		default {
		    $*ERR.say: "error in $ref$ent: $_"; 
		}
	    }
	}
	check($kid, :ent("\[$_\]"), :$depth)  if $kid ~~ Array | Hash;
    }
}

multi sub check($obj) is default {}

#| check contents of a Page, XObject Form or Pattern
sub check-contents( $obj, Str :$ref!) {

    my Array $ast = $obj.contents-parse;

    # cross check with the resources directory
    my $resources = $obj.Resources
	// die "no /Resources dict found";

    use PDF::Content::Ops;
    my PDF::Content::Ops $ops .= new(:$*strict);

    for $ast.list {
	$ops.op($_);
	my $entry;
	my UInt $name-idx = 0;

	my Str $type = do given .key {
	    when 'cs' | 'CS'  { 'ColorSpace' }
	    when 'BDC' | 'DP' { $name-idx = 1; 'Properties'}
	    when 'Do'         { 'XObject' }
	    when 'Tf'         { 'Font' }
	    when 'gs'         { 'ExtGState' }
	    when 'scn'        { 'Pattern' }
	    when 'sh'         { 'Shading' }
	    default {''}
        };

	if $type && .value[$name-idx].key eq 'name' {
	    my Str $name = .value[$name-idx].value;
	    warn "no resources /$type /$name entry for '{.key}' operator"
	        unless $resources{$type}:exists && ($resources{$type}{$name}:exists);
	}
    }

    $ops.finish;

    CATCH {
	default {
	    $*ERR.say: "unable to parse {$ref}contents: $_"; 
	}
    }
}

=begin pod

=head1 NAME

pdf-checker.p6 - Check PDF DOM structure and values

=head1 SYNOPSIS

 pdf-checker.p6 [options] file.pdf

 Options:
   --password   password for an encrypted PDF
   --max-depth  max DOM navigation depth (default 100)
   --trace      trace DOM navigation
   --contents   check the contents of pages, forms and patterns
   --strict     enble some additonal warnings:
                -- unknown entries in dictionarys
                -- additional graphics checks (when --contents is enabled)

=head1 DESCRIPTION

Checks a PDF against the DOM. Traverses all objects in the PDF that are accessable from the root, reporting any errors or warnings that were encountered. 

=head1 SEE ALSO

PDF

=head1 AUTHOR

See L<PDF>

=end pod
