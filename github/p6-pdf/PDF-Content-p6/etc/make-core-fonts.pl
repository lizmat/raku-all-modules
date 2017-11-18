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

    method !build-enc(IO::Path $encoding-path, Hash :$glyphs! is rw, Hash :$encodings! is rw) {
        my $encoding-io = $encoding-path;

        die "unable to load encodings: $encoding-path"
            unless $encoding-path ~~ :e;

        my %charset = %Font::AFM::Glyphs.invert;

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
                :win(@enc[2]) {
                my ($scheme, $byte) = .kv;
                next unless $byte.defined;
                my $enc = $encodings{$scheme} //= {}
                my $dec = $glyphs{$scheme} //= {}
                self!save-glyph(:glyphs($dec), :encoding($enc), $glyph-name, $chr, $byte);

                with %charset{$glyph-name} -> $alternate-chr {
                    if $alternate-chr ne $chr {
                        self!save-glyph(:glyphs($dec), $glyph-name, $alternate-chr, $byte);
                    }
                }
            }
        }
    }

    method !build-sym-enc(IO::Path $encoding-path, Str :$sym = 'sym', Hash :$glyphs! is rw, Hash :$encodings! is rw) {
        my $encoding-io = $encoding-path;

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
            my $char = :16( $<code-point>.Str ).chr;
            my $byte = :16( $<encoding>.Str ).chr;
            $glyphs{$sym}{$char} = $glyph-name;
            $encodings{$sym}{$glyph-name} = $byte;
        }
    }

    method !write-enc(Hash :$glyphs! is rw, Hash :$encodings! is rw) {
        my $lib-dir = $*SPEC.catdir('lib', 'PDF', 'Content', 'Font');
        mkdir( $lib-dir, 0o755);

        my $module-name = "PDF::Content::Font::Encodings";
        my $gen-path = $*SPEC.catfile($lib-dir, "Encodings.pm");
        my $*OUT = open( $gen-path, :w);

        print q:to"--CODE-GEN--";
        use v6;
        # Single Byte Font Encodings
        #
        # DO NOT EDIT!!!
        #
        # This file was auto-generated

        module PDF::Content::Font::Encodings {

        --CODE-GEN--

        for $glyphs.keys.sort -> $type {
            say "    #-- {$type.uc} encoding --#"; 
            say "    constant \${$type}-glyphs = {$glyphs{$type}.perl};"
                if $type eq 'zapf';
            say "    constant \${$type}-encoding = {$encodings{$type}.perl};";
            say "";
        }

        say '}';
    }

   method build {

       my $glyphs = {};
       my $encodings = {};
       self!build-enc("etc/encodings.txt".IO, :$glyphs, :$encodings);
       self!build-sym-enc("etc/symbol.txt".IO, :$glyphs, :$encodings);
       self!build-sym-enc("etc/zdingbat.txt".IO, :sym<zapf>, :$glyphs, :$encodings);
       self!write-enc(:$glyphs, :$encodings);
    }
}

# Build.pm can also be run standalone 
sub MAIN {

    Build.new.build;
}

