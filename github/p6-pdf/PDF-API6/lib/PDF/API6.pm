use v6;
use PDF::Class;

class PDF::API6:ver<0.1.0>
    is PDF::Class {

    use PDF::COS;
    use PDF::Catalog;
    use PDF::Info;
    use PDF::Metadata::XML;
    use PDF::Page;
    use PDF::Destination :Fit;

    sub nums($a, Int $n) {
        with $a {
            fail "expected $n elements, found {.elems}"
                unless $n == .elems;
            fail "array contains non-numeric elements"
                unless all(.list) ~~ Numeric;
        }
        True;
    }
    sub to-name(Str $name) { PDF::COS.coerce: :$name }

    subset PageRef where {!.defined || $_ ~~ UInt|PDF::Page};

    method preferences(
        Bool :$hide-toolbar,
        Bool :$hide-menubar,
        Bool :$hide-windowui,
        Bool :$fit-window,
        Bool :$center-window,
        Bool :$display-title,
        Str  :$direction where 'r2l'|'l2r'|!.defined,
        Str  :$page-mode where 'fullscreen'|'thumbs'|'outlines'|'none' = 'none';
        Str  :$page-layout where 'single-page'|'one-column'|'two-column-left'|'two-column-right' = 'single-page';
        Str  :$after-fullscreen where 'thumbs'|'outlines'|'none'='none',
        Str  :$print-scaling where 'none'|!.defined,
        Str  :$duplex where 'simplex'|'flip-long-edge'|'flip-short-edge'|!.defined,
        :%start (
            PageRef :$page is copy = 1,
            :$fit = FitWindow,
        ),
        ) {
        my PDF::Catalog $catalog = $.catalog;

        constant %PageModes = %(
            :fullscreen<FullScreen>,
            :thumbs<UseThumbs>,
            :outline<UseOutlines>,
            :none<UseNone>,
            );

        $catalog.PageMode = %PageModes{$page-mode};

        $catalog.PageLayout = %(
            :single-page<SinglePage>,
            :one-column<OneColumn>,
            :two-column-left<TwoColumnLeft>,
            :two-column-right<TwoColumnRight>,
            :single-page<SinglePage>,
            ){$page-layout};

        given $catalog.ViewerPreferences //= { } -> $p {
            $p.HideToolbar = $_ with $hide-toolbar;
            $p.HideMenubar = $_ with $hide-menubar;
            $p.HideWindowUI = $_ with $hide-windowui;
            $p.FitWindow = $_ with $fit-window;
            $p.CenterWindow = $_ with $center-window;
            $p.DisplayDocTitle = $_ with $display-title;
            $p.Direction = $p.uc with $direction;
            $p.NonFullScreenPageMode = %PageModes{$after-fullscreen};
            $p.PrintScaling = 'None' if $print-scaling ~~ 'none';
            with $duplex {
                $p.Duplex = %(
                      :simplex<Simplex>,
                      :flip-long-edge<DuplexFlipLongEdge>,
                      :flip-short-edge<DuplexFlipShortEdge>,
                    ){$_};
            }
        }
        $page = self.page($page) if $page ~~ Numeric;
        $catalog.OpenAction = PDF::Destination.construct($fit, |%start, :$page);
    }

    method is-encrypted { ? self.Encrypt }
    method info returns PDF::Info { self.Info //= {} }
    method xmp-metadata is rw {
        my PDF::Metadata::XML $metadata = $.catalog.Metadata //= {
            :Type( to-name(<Metadata>) ),
            :Subtype( to-name(<XML>) ),
        };

        $metadata.decoded; # rw target
    }

    our Str enum PageLabel «
         :Decimal<d>
         :Roman<R> :RomanUpper<R> :RomanLower<r>
         :Alpha<A> :AlphaUpper<A> :AlphaLower<a>
        »;

    sub to-page-label(Hash $l) {
        my % = $l.keys.map: {
            when 'style'  { S  => to-name($l{$_}.Str) }
            when 'start'  { St => $l{$_}.Int }
            when 'prefix' { P  => to-name($l{$_}.Str) }
            default { warn "ignoring PageLabel field: $_" }
        }
    }

    subset PageLabelEntry of Pair where {.key ~~ UInt && .value ~~ Hash }

    sub to-page-labels(Pair @labels) {
        my @page-labels;
        my UInt $seq;
        my UInt $n = 0;
        for @labels {
            my $idx  = .key;
            my $dict = .value;
            ++$n;
            fail "out of sequence PageLabel index at offset $n: $idx"
                if $seq.defined && $idx <= $seq;
            $seq = $idx;
            @page-labels.push: $seq;
            @page-labels.push: to-page-label($dict);
        }
        @page-labels;
    }

    sub from-page-label(Hash $l --> Hash) {
        my % = $l.keys.map: {
            when 'S'  { style  => $l{$_} }
            when 'St' { start  => $l{$_} }
            when 'P'  { prefix => $l{$_} }
            default   { $_ => $l{$_} }
        }
    }

    sub from-page-labels(Hash $labels) {
        my PageLabelEntry @page-labels;
        my UInt $n = 0;
        with $labels<Nums> {
            my $elems = .elems;
            while ($n < $elems) {
                my UInt $idx  = .[$n++];
                my $dict = .[$n++] // {};
                @page-labels.push: $idx => from-page-label($dict);
            }
        }
        else {
            with $labels<Kids> {
                @page-labels.append: from-page-labels($_)
                    for .list
            }
        }
        @page-labels;
    }

    method page-labels {
        Proxy.new(
            STORE => sub ($, List $_) {
                my PageLabelEntry @labels = .list;
                $.catalog.PageLabels = %( Nums => to-page-labels(@labels) );
            },
            FETCH => sub ($) {
                from-page-labels($.catalog.PageLabels);
            },
        )
    }

    method fields {
        .fields with $.catalog.AcroForm;
    }

    method fields-hash {
        .fields-hash with $.catalog.AcroForm;
    }

    use PDF::Function::Sampled;
    use PDF::ColorSpace::Separation;
    subset DeviceColor of Pair where .key eq 'DeviceRGB'|'DeviceCMYK'|'DeviceGray';
    method color-separation(Str $name, DeviceColor $color --> PDF::ColorSpace::Separation) {
        my @Range;
        my List $v = $color.value;
        my Str $encoded;
        given $color.key {
            when 'DeviceRGB' {
                @Range = $v[0],1, $v[1],1, $v[2],1;
                $encoded = 'FF' x 3   ~  '00' x 3  ~  '>';
            }
            when 'DeviceCMYK' {
                @Range = 0,$v[0], 0,$v[1], 0,$v[2], 0,$v[3];
                $encoded = '00' x 4  ~  'FF' x 4  ~  '>';
            }
            when 'DeviceGray' {
                @Range = 0,$v[1];
                $encoded = 'FF00>';
            }
        }

        my %dict = :Domain[0,1], :@Range, :Size[2,], :BitsPerSample(8), :Filter( :name<ASCIIHexDecode> );
        my PDF::Function::Sampled $function .= new: :%dict, :$encoded;
        PDF::COS.coerce: [ :name<Separation>, :$name, :name($color.key), $function ];
    }

    method color-devicen(@colors) {
        my $nc = +@colors;
        my @functions;
        for @colors {
            die "color is not a seperation"
                unless $_ ~~ PDF::ColorSpace::Separation;
            die "unsupported colorspace(s): {.[2]}"
                unless .[2] ~~ 'DeviceCMYK';
            my $function = .TintTransform.calculator;
            die "unsupported colorspace transform: {.TintTransform.perl}"
                unless $function.domain.elems == 1
                && $function.range.elems == 4;
            @functions.push: $function;
        }
        my @Domain = flat (0, 1) xx $nc;
        my @Range = flat (0, 1) xx 4;
        my @Size = 2 xx $nc;

        # create approximate compound function based on ranges only.
        # Adapted from Perl 5's PDF::API2::Resource::ColorSpace::DeviceN
        my @xclr = @functions.map: {.calc([.domain>>.max])};
        my constant Sampled = 2;
        my Numeric @spec[Sampled ** $nc;4];

        for 0 ..^ $nc -> $xc {
            for 0 ..^ (Sampled ** $nc) -> $n {
                my \factor = ($n div (Sampled**$xc)) % Sampled;
                my @thiscolor = @xclr[$xc].map: { ($_ * factor)/(Sampled-1) };
                for 0..3 -> $s {
                    @spec[$n;$s] += @thiscolor[$s];
                }
            }
        }

        my buf8 $decoded .= new: @spec.flat.map: {(min($_,1.0) * 255).round};

        my %dict = :@Domain, :@Range, :@Size, :BitsPerSample(8), :Filter( :name<ASCIIHexDecode> );
        my @names = @colors.map: *.Name;
        my %Colorants = @names Z=> @colors;

        my PDF::Function::Sampled $function .= new: :%dict, :$decoded;
        PDF::COS.coerce: [ :name<DeviceN>, @names, :name<DeviceCMYK>, $function, { :%Colorants } ];
    }
}
