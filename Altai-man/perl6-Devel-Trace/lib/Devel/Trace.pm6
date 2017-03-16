unit module Devel::Trace;

my %sources;

my class SourceFile {
    has $.filename;
    has $.source;
    has @!lines;

    method BUILD(:$!filename, :$!source) {
        # Ensure source ends with a newline.
        unless $!source ~~ /\n$/ {
            $!source ~= "\n";
        }

        # Store (abbreviated if needed) lines.
        @!lines = lines($!source).map(-> $l {
					     $l.chars > 77 ?? $l.substr(0, 74) ~ '...' !! $l
					 });
	my $i = 0;
    }
    method say_line($from, $to) {
	my $line-number = $!source.substr(0, $to).lines.elems;
	say "./$.filename:$line-number: " ~ $.source.substr($from, $to - $from);
    }

}

$*DEBUG_HOOKS.set_hook('new_file', -> $filename, $source {
			      %sources{$filename} = SourceFile.new(:$filename, :$source);
			  });

$*DEBUG_HOOKS.set_hook('statement_simple', -> $filename, $ctx, $from, $to {
			      %sources{$filename}.say_line($from, $to);
			  });


$*DEBUG_HOOKS.set_hook('statement_cond', -> $filename, $ctx, $type, $from, $to {
			      %sources{$filename}.say_line($from, $to);
			  });

sub EXPORT is DEPRECTATED("This module is redundant, just put 'use trace;' in your source instead!") {}
