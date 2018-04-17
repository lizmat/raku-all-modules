#!/usr/bin/env perl6
use v6;

use PDF::Class;
use PDF::Content::Graphics;
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
sub MAIN(Str $infile,               #= input PDF
         Str  :$password = '',      #= password for the input PDF, if encrypted
         Bool :$*trace,             #= show progress
         Bool :$*contents,          #= validate/check contents of pages, etc
         Bool :$*strict,            #= perform additional checks
         UInt :$*max-depth = 100,   #= maximum recursion depth
	 Str  :$exclude,            #= excluded entries: Entry1,Entry2,
         Bool :$repair = False      #= repair PDF before checking
         ) {

    my $doc = PDF::Class.open( $infile, :$password, :$repair );
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
    die "maximum depth of $*max-depth exceeded $ent: $ref"
	if ++$depth > $*max-depth;
    my Hash $entries = $obj.entries;
    my Str @unknown-entries;

    check-contents($obj, :$ref)
	if $*contents && $obj.does(PDF::Content::Graphics);

     my %missing = $entries.pairs.grep(*.value.tied.is-required);

    for $obj.keys.sort -> $k {

        %missing{$k}:delete;
        # Avoid following /P back to page then back here via page /Annots
        next if $k eq 'P' && $obj.isa(PDF::Annot);
	next if @*exclude.grep: $k;
	my $kid;

	do {
	    $kid = $entries{$k}:exists
		?? $obj."$k"()   # entry has an accessor. use it
		!! $obj{$k};     # dereferece hash entry

	    CATCH {
		default {
		    $*ERR.say: "error in $ref /$k entry: $_";
		}
	    }
	}

	check($kid, :ent("/$k"), :$depth) if $kid ~~ Array | Hash;

	@unknown-entries.push: '/' ~ $k
	    if $*strict && +$entries && !($entries{$k}:exists);
    }

    $*ERR.say: "error in $ref {$obj.WHAT.^name}, missing required field(s): {%missing.keys.sort.join(', ')}"
        if %missing;

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
    die "maximum depth of $*max-depth exceeded $ent: $ref"
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
		    $*ERR.say: "error in $ref $ent: $_";
		}
	    }
	}
	check($kid, :ent("\[$_\]"), :$depth)  if $kid ~~ Array | Hash;
    }
}

multi sub check($obj) is default {}

#| check contents of a Page, XObject Form, Pattern or CharProcs
sub check-contents( $obj, Str :$ref!) {

    my Array $ast = $obj.contents-parse;

    # cross check with the resources directory
    my $resources = $obj.?Resources // {};

    use PDF::Content::Ops;
    my PDF::Content::Ops $ops .= new(:$*strict);

    for $ast.list -> $op {
	$ops.op($op);
	my $entry;
	my UInt $name-idx = 0;

	my Str $type = do given $op.key {
	    when 'BDC' | 'DP' { $name-idx = 1; 'Properties'}
	    when 'Do'         { 'XObject' }
	    when 'Tf'         { 'Font' }
	    when 'gs'         { 'ExtGState' }
	    when ($_ ~~ 'scn'|'SCN')
            && $op.value.tail.key ~~ 'name' {
                $name-idx = $op.value.elems - 1;
                'Pattern'
            }
	    when 'sh'         { 'Shading' }
	    default {''}
        };

	if $type && $op.value[$name-idx].key eq 'name' {
	    my Str $name = $op.value[$name-idx].value;
	    warn "no resources /$type /$name entry for '{$op.key}' operator"
	        unless $resources{$type}:exists && ($resources{$type}{$name}:exists);
	}
    }

    $ops.finish;

    CATCH {
	default {
	    $*ERR.say: "unable to process {$ref}contents: $_"; 
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
   --max-depth  max navigation depth (default 100)
   --trace      trace PDF navigation
   --contents   check the contents of pages, forms, patterns and type3 fonts
   --strict     enble some additonal warnings:
                -- unknown entries in dictionarys
                -- additional graphics checks (when --contents is enabled)

=head1 DESCRIPTION

Checks a PDF class structure. Traverses all objects in the PDF that are accessable from the root, reporting any errors or warnings that were encountered. 

=head1 SEE ALSO

PDF

=head1 AUTHOR

See L<PDF>

=end pod
