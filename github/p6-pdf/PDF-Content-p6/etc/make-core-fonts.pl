use v6;

use Font::AFM;

class Build {

    method !save-glyph(Str $glyph-name, $chr, $ord, Hash :$encoding, Hash :$glyphs) {

            .{$glyph-name} //= $ord.chr
                with $encoding;

            # $chr.ord isn't unique? use NFD as index
            .{$chr} //= $glyph-name
                with $glyphs;
    }

    method !build-enc(IO::Path $encoding-path) {
        my $encoding-io = $encoding-path;

        die "unable to load encodings: $encoding-path"
            unless $encoding-path ~~ :e;

        my %encodings = :mac(array[uint16].new(0 xx 256)), :win(array[uint16].new(0 xx 256)), :std(array[uint16].new(0 xx 256));

        for $encoding-path.lines {
            next if /^ '#'/ || /^ $/;
            m:s/^$<char>=. $<glyph-name>=\w+ [ $<enc>=[\d+|'—'] ]** 4 $/
               or do {
                   warn "unable to parse encoding line: $_";
                   next;
               };

            my $glyph-name = ~ $<glyph-name>;
            my @enc = @<enc>.map( {
                .Str eq '—' ?? Mu !! :8(.Str);
            } );

            my $chr = $<char>.Str;

            for :mac(@enc[1]),
                :win(@enc[2]),
                :std(@enc[0]) {
                my ($scheme, $byte) = .kv;
                next unless $byte.defined;
                my $enc := %encodings{$scheme};
                $enc[$byte] = $chr.ord;
            }
        }
        for <mac win std> -> $type {
            say "    #-- {$type.uc} encoding --#";
            say "    constant \${$type}-encoding = {%encodings{$type}.perl};";
            say "";
        }
    }

    method !build-sym-enc(IO::Path $encoding-path, :$type!, :$glyphs) {
        my $encoding-io = $encoding-path;
        my uint16 @encodings = 0 xx 256;
        my %glyphs;

        die "unable to load encodings: $encoding-path"
            unless $encoding-path ~~ :e;

        for $encoding-path.lines {
            next if /^ '#'/ || /^ $/;
            m:s/^ $<code-point>=[<xdigit>+] $<encoding>=[<xdigit>+] .*? $<glyph-name>=[\w+] $<comment>=['(' .*? ')']? $/
               or do {
                   warn "unable to parse encoding line: $_";
                   next;
               };

            my $glyph-name = ~ $<glyph-name>;
            my uint16 $code-point = :16( ~$<code-point> );
            my uint8  $encoding = :16( $<encoding>.Str );
            %glyphs{$code-point.chr} = $glyph-name;
            @encodings[$encoding] ||= $code-point;
        }
        say "    #-- {$type.uc} encoding --#";
        say "    constant \${$type}-glyphs = {%glyphs.perl};"
            if $glyphs;
        say "    constant \${$type}-encoding = {@encodings.perl};";
        say ""
    }

    method !write-enc-header {

        print q:to"--CODE-GEN--";
        use v6;
        # Single Byte Font Encodings
        #
        # DO NOT EDIT!!!
        #
        # This file was auto-generated

        module PDF::Content::Font::Encodings {
        --CODE-GEN--
    }

    method build {
        my $lib-dir = $*SPEC.catdir('lib', 'PDF', 'Content', 'Font');
        mkdir( $lib-dir, 0o755);

        my $module-name = "PDF::Content::Font::Encodings";
        my $gen-path = $*SPEC.catfile($lib-dir, "Encodings.pm");
        my $*OUT = open( $gen-path, :w);
        self!write-enc-header;
        self!build-enc("etc/encodings.txt".IO);
        self!build-sym-enc("etc/symbol.txt".IO, :type<sym>);
        self!build-sym-enc("etc/zdingbat.txt".IO, :type<zapf>, :glyphs);
        say '}';
    }
}

# Build.pm can also be run standalone 
sub MAIN {

    Build.new.build;
}

