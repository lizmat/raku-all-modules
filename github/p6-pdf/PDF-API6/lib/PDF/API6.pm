use v6;
use PDF::Lite:ver(v0.0.2+);

class PDF::API6:ver<0.0.1>
    is PDF::Lite {

    use PDF::DAO;
    use PDF::Content::Page;

    sub nums($a, Int $n) {
        with $a {
            fail "expected $n elements, found {.elems}"
                unless $n == .elems;
            fail "array contains non-numeric elements"
                unless all(.list) ~~ Numeric;
        }
        True;
    }
    sub to-name(Str $name) { PDF::DAO.coerce: :$name }

    subset PageRef where {!.defined || $_ ~~ UInt|PDF::Content::Page};

    method open(|c) {
	my $doc = callsame;
	die "PDF file has wrong type: " ~ $doc.reader.type
	    unless $doc.reader.type eq 'PDF';
	$doc;
    }

    method catalog { self<Root> }

    method save-as($spec, Bool :$preserve is copy, |c) {

	if !$preserve and self.reader {
            with $.catalog<AcroForm> {
                # guard against signature invalidation
                with .<SigFlags> {
                    constant AppendOnly = 2;
                    if .flag-is-set(AppendOnly) {
                        with $preserve {
                            die "This PDF contains digital signatures that will be invalidated with .save-as :!preserve"
                        }
                        else {
                            # save in :preserve mode to preserve digital signatures
                            $_ = True
                        }
                    }
                }
            }
	}

        do {
            my $now = DateTime.now;
            my $info = self.info;

            with self.reader {
                # updating
                $info<ModDate> = $now;
            }
            else {
                # creating
                $info<Producer> //= "Perl 6 PDF::API6 {self.^ver}";
                $info<CreationDate> //= $now
            }
        }
	nextwith($spec, :$preserve, |c);
    }

    method update(|c) {
        # for the benefit of the test suite
        my $now = DateTime.now;
        my $Info = self<Info> //= {};
        $Info<ModDate> = $now;
        nextsame;
    }

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
        Str :$after-fullscreen where 'thumbs'|'outlines'|'none'='none',
        Str :$print-scaling where 'none'|!.defined,
        Str :$duplex where 'simplex'|'flip-long-edge'|'flip-short-edge'|!.defined,
        :%first-page (
            PageRef :$page,
            Bool    :$fit,
            Numeric :$fith,
            Bool    :$fitb,
            Numeric :$fitbh,
            Numeric :$fitv,
            Numeric :$fitbv,
            List    :$fitr where nums($_, 4),
            List    :$xyz where nums($_, 3),
        ) where { .keys == 0 || .<page> }
        ) {
        my $catalog = $.catalog;

        constant %PageModes = %(
            :fullscreen<FullScreen>,
            :thumbs<UseThumbs>,
            :outline<UseOutlines>,
            :none<UseNone>,
            );

        $catalog<PageMode> = to-name( %PageModes{$page-mode} );

        $catalog<PageLayout> = to-name( %(
            :single-page<SinglePage>,
            :one-column<OneColumn>,
            :two-column-left<TwoColumnLeft>,
            :two-column-right<TwoColumnRight>,
            :single-page<SinglePage>,
            ){$page-layout});

        given $catalog<ViewerPreferences> //= { } {
            .<HideToolbar> = True if $hide-toolbar;
            .<HideMenubar> = True if $hide-menubar;
            .<HideWindowUI> = True if $hide-windowui;
            .<FitWindow> = True if $fit-window;
            .<CenterWindow> = True if $center-window;
            .<DisplayDocTitle> = True if $display-title;
            .<Direction> = to-name(.uc) with $direction;
            .<NonFullScreenPageMode> = to-name( %PageModes{$after-fullscreen});
            .<PrintScaling> = to-name('None') if $print-scaling ~~ 'none';
            with $duplex -> $dpx {
                .<Duplex> = to-name( %(
                      :simplex<Simplex>,
                      :flip-long-edge<DuplexFlipLongEdge>,
                      :flip-short-edge<DuplexFlipShortEdge>,
                    ){$dpx});
            }
        }
        if $page {
            my $page-ref = $page ~~ Numeric
                ?? self.page($page)
                !! $page;
            my $open-action = [$page-ref];
            with $open-action {
                when $fit   { .push: to-name('Fit') }
                when $fith  { .push($fith) }
                when $fitb  { .push: to-name('FitB') }
                when $fitbh {
                    .push: to-name('FitBH');
                    .push: $fitbh;
                }
                when $fitv {
                    .push: to-name('FitV');
                    .push: $fitv;
                }
                when $fitbv {
                    .push: to-name('FitBV');
                    .push: $fitbv;
                }
                when $fitr {
                    .push: to-name('FitR');
                    for $fitr.list -> $v {
                        .push: $v;
                    }
                }
                when $xyz {
                    .push: to-name('XYZ');
                    for $xyz.list -> $v {
                        .push: $v;
                    }
                }
                default {
                    .push: to-name('Fit');
                }
            }
            $catalog<OpenAction> = $open-action;
        }
    }

    method version {
        Proxy.new(
            FETCH => sub ($) {
                Version.new: $.catalog<Version> // self.reader.?version // '1.3'
            },
            STORE => sub ($, Version $v) {
                $.catalog<Version> = to-name( $v.Str );
            },
        );
    }

    method is-encrypted { ? self.Encrypt }
    method info { self.Info //= {} }
    method xmp-metadata is rw {
        my $metadata = $.catalog<Metadata> //= PDF::DAO.coerce: :stream{
            :dict{
                :Type( to-name(<Metadata>) ),
                :Subtype( to-name(<XML>) ),
            }
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
            when 'style'|'S'  { S  => to-name($l{$_}.Str) }
            when 'start'|'St' { St => $l{$_}.Int }
            when 'prefix'|'P' { P  => to-name($l{$_}.Str) }
            default { warn "ignoring PageLabel field: $_" } 
        }
    }

    subset PageLabelEntry of Pair where {.key ~~ UInt && .value ~~ Hash }

    sub to-page-labels($labels) {
        my @page-labels;
        my UInt $seq;
        my UInt $n = 0;
        for $labels.list {
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

    sub from-page-label(Hash $l) {
        my % = $l.keys.map: {
            when 'S'  { style  => $l{$_} }
            when 'St' { start  => $l{$_} }
            when 'P'  { prefix => $l{$_} }
            default   { $_ => $l{$_} }
        }
    }

    sub from-page-labels(Hash $labels) {
        my @page-labels;
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
                $.catalog<PageLabels> = %( Nums => to-page-labels(@labels) );
            },
            FETCH => sub ($) {
                from-page-labels($.catalog<PageLabels>);
            }
            )
    }

}
