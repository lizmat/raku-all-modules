#!/usr/bin/env perl6
use v6;
use PDF::Content;
use PDF::Content::Graphics;
use PDF::Writer;
use PDF::COS::TextString;
use PDF::COS::Util :to-ast;

my Bool $*contents;
my Bool $*trace;
my Bool $*strict = False;
my PDF::Writer $*writer .= new;
my Str @*exclude;
my %indobj-seen;
my Int $warnings = 0;
my Int $errors = 0;

my subset Annot of Hash where .<Type> ~~ 'Annot';

sub error($msg) {
    $*ERR.say: $msg;
    $errors++;
}

sub warning($msg) {
    $*ERR.say: $msg;
    $warnings++;
}

sub key-sort($_) {
    when 'Type'        {"0"}
    when 'Subtype'|'S' {"1"}
    when /Type$/       {"1" ~ $_}
    when 'Length'      {"z"}
    default            {$_}
}

sub display-item($_) {
    when Hash|Array {
        my $obj-num = .?obj-num;
        $obj-num && $obj-num > 0
            ?? ref($_)
            !! '...';
    }
    when PDF::COS::TextString { .Str.perl }
    default {
        given to-ast($_) {
            .key ~~ 'hex-string'
                ?? .value.perl
                !! $*writer.write($_)
        }
    }
}

multi sub display(List $obj) {
    '[ ' ~ (
        $obj.keys.map({ $obj[$_] })
            .map({display-item($_)})
            .join: ' ')
        ~ ' ]';
}

multi sub display(Hash $obj) {
    '<< ' ~ (
        $obj.keys.grep(* ne 'encoded').sort(&key-sort)
            .map(-> $name { :$name, $obj{$name} })
            .flat
            .map({display-item($_)}).join: ' ')
        ~ ' >>';
}

sub ref($obj) {
    my $obj-num = $obj.obj-num;
    $obj-num && $obj-num > 0
	?? "{$obj.obj-num} {$obj.gen-num//0} R"
        !! display($obj)
}

#| check a PDF against PDF class definitions
sub MAIN(Str $infile,                 #= input PDF
         Str  :$password = '',        #= password for the input PDF, if encrypted
         Str  :$class = 'PDF::Class', #= open with this class (default PDF::Class)
         Bool :$*trace,               #= show progress
         Bool :$*render,              #= validate/check contents of pages, etc
         Bool :$*strict,              #= perform additional checks
	 Str  :$exclude,              #= excluded entries: Entry1,Entry2,
         Bool :$repair = False        #= repair PDF before checking
         ) {

    CONTROL {
        when CX::Warn {
            note "Warning: $_";
            $warnings++;
            .resume
        }
    }
    my $pdf = (require ::($class)).open( $infile, :$password, :$repair );
    @*exclude = $exclude.split(/:s ',' /)
    	      if $exclude;
    check( $pdf, :ent<xref> );
    $*ERR.say: "Checking of $infile completed with $warnings warnings and $errors errors";
}

sub show-type($obj where Array|Hash) {
    my $name = ~ $obj.WHAT.^name;
    $name ~= [~] '[', .type.^name, ']'
        with $obj.of-att;
    $name;
}

|# Recursively check a dictionary (array) object
multi sub check(Hash $obj, UInt :$depth is copy = 0, Str :$ent = '') {
    my $obj-num = $obj.obj-num;
    return
        if $obj-num && $obj-num > 0
           && %indobj-seen{"$obj-num {$obj.gen-num}"}++;
    $*ERR.say: (" " x ($depth++*2)) ~ "$ent\:\t{display($obj)}\t% {show-type($obj)}"
        if $*trace;

    my Hash $entries = $obj.entries;
    my Str @unknown-entries;

     my %required = $entries.pairs.grep(*.value.tied.is-required);

    for $obj.keys.sort -> $k {
        %required{$k}:delete;
        # Avoid following /P back to page then back here via page /Annots, which tends to be deeply recursive and difficult to follow
        next if $k eq 'P' && $obj ~~ Annot;
	next if @*exclude.grep: $k;
	my $kid;

	do {
	    $kid = $entries{$k}:exists
		?? $obj."$k"()   # entry has an accessor. use it
		!! $obj{$k};     # dereferece hash entry

            check($kid, :ent("/$k"), :$depth) if $kid ~~ Array | Hash;

	    CATCH {
		default {
		    error("Error in {ref($obj)} ({show-type($obj)}) /$k entry: $_");
		}
	    }
	}

	@unknown-entries.push: '/' ~ $k
	    if $*strict && +$entries && !($entries{$k}:exists);
    }

    if %required {
        error("Error in {ref($obj)} ({show-type($obj)}), missing required field(s): {%required.keys.sort.join(', ')}")
    }
    else {
        do {
            $obj.?cb-check();
            CATCH {
                default {
                    error("Error in {ref($obj)} ({show-type($obj)}) record: $_");
                }
            }
        }
    }
    warning("Unknown entries {ref($obj)} ({show-type($obj)}) struct: @unknown-entries[]")
        if @unknown-entries;

    check-contents($obj, :$depth)
	if $*render && $obj.does(PDF::Content::Graphics);

}

#| Recursively check an array object
multi sub check(Array $obj, UInt :$depth is copy = 0, Str :$ent = '') {
    my $obj-num = $obj.obj-num;
    return
        if $obj-num && $obj-num > 0
           && %indobj-seen{"$obj-num {$obj.gen-num}"}++;

    $*ERR.say: (" " x ($depth++*2)) ~ "$ent\:\t{display($obj)}\t% {show-type($obj)}"
        if $*trace;

    my Array $index = $obj.index;
    for $obj.keys.sort -> $i {
	my Str $accessor = .tied.accessor-name
	    with $index[$i];
	my $kid;
	do {
	    $kid = $accessor
		?? $obj."$accessor"()  # array element has an accessor. use it
		!! $obj[$i];           # dereference array element

            check($kid, :ent("\[$i\]"), :$depth)  if $kid ~~ Array | Hash
                && !($i == 0 && $accessor ~~ 'page'); # avoid recursing to page destinations

	    CATCH {
		default {
		    error("error in {ref($obj)}\[$i\] ({show-type($obj)}) $ent: $_");
		}
	    }
	}
    }
}

multi sub check($obj) is default {}

#| check contents of a Page, XObject Form, Pattern or CharProcs
sub check-contents( $obj, :$depth ) {

    # cross check with the resources directory
    my $resources = $obj.?Resources // {};

    my &callback = sub ($op, *@args) {
        my UInt $name-idx = 0;
        my Str $type = do given $op {
            when 'BDC'|'DP'  { $name-idx = 1; 'Properties'}
            when 'Do'        { 'XObject' }
            when 'Tf'        { 'Font' }
            when 'gs'        { 'ExtGState' }
            when 'scn'|'SCN' {
                if @args.tail ~~ Str {
                    $name-idx = @args.elems - 1;
                    'Pattern'
                }
                else { Nil }
            }
            when 'sh'        { 'Shading' }
            default {Nil}
        };

        with $type {
            if @args[$name-idx] ~~ Str {
                my Str $name = @args[$name-idx];
                warn "No resources /$_ /$name entry for '$op' operator"
                    without ($resources{$_} // {}){$name};
            }
        }
    }

    my $render-warnings;
    CONTROL {
        when CX::Warn {
            unless $render-warnings++ {
                $*ERR.print: (" " x ($depth*2))
                    if $*trace;
                $*ERR.print: "Rendering warning(s)";
                $*ERR.print: " in {ref($obj)} ({show-type($obj)})"
                    unless $*trace;
                $*ERR.say: ":";
            }
            $*ERR.print: (" " x ($depth*2))
                if $*trace;
            $*ERR.say: "-- $_";
            $warnings++;
            .resume
        }
    }
    my $gfx = $obj.render: :$*strict, :&callback;
    $gfx.finish;

    CATCH {
	default {
	    error("Unable to render {ref($obj)} contents: $_");
	}
    }
}

=begin pod

=head1 NAME

pdf-checker.p6 - Check PDF structure and values

=head1 SYNOPSIS

 pdf-checker.p6 [options] file.pdf

 Options:
   --password          password for an encrypted PDF
   --trace             trace PDF navigation
   --render            check the contents streams of pages, forms, patterns and type3 fonts
   --strict            enable some additional warnings:
                       -- unknown entries in dictionarys
                       -- additional graphics checks (when --render is enabled)
   --class <name>      checking class (default PDF::Class)
   --exclude <key>,..  restrict checking
   --repair            Repair PDF before Checking

=head1 DESCRIPTION

Checks a PDF class structure. Traverses all objects in the PDF that are accessable from the root, reporting any errors or warnings that were encountered. 

=head1 SEE ALSO

PDF

=head1 AUTHOR

See L<PDF>

=end pod
