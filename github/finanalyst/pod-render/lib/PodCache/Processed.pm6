use v6.c;
use PodCache::Engine;
constant TOP = '___top'; # the name of the anchor at the top of a source file
constant FRONT-MATTER = 'Introduction'; # Text between =TITLE and first header
use URI;
use LibCurl::Easy;

unit class PodCache::Processed;
    has Str $.name;
    has Str $.title is rw = $!name;
    has Str $.subtitle is rw = '';
    has Str $.path; # may/may not exist, but is path of original document
    has Str $.top is rw; # defaults to top, then becomes target for TITLE
    has $.pod-tree; # cached pod
    has Str $.pod-body; # rendition of whole source
    has Instant $.when-rendered; # when rendered if successful
    has @.toc = ();
    has %.index = ();
    has @.links = (); # for links referenced
    has @.footnotes = ();
    has SetHash $.targets .= new; # target names are relative to Processed
    has Int @.counters is default(0);
    has Bool $.debug is rw;
    has Bool $.verbose;
    has @.itemlist = (); # for multilevel lists
    has @.metalist = ();
    has Bool $!collection-unique;
    has $!file-ext = 'html'; # most likely
    has Bool $!in-defn-list = False;
    has PodCache::Engine $.engine ;
    has &.highlighter;

    submethod BUILD  (
        :$!name,
        :$!title = $!name,
        :$!pod-tree,
        :$!debug = False,
        :$!verbose = False,
        :$!engine = PodCache::Engine.new,
        :$!collection-unique = False,
        :$!path = '',
        :&!highlighter,
        ) { }

    submethod TWEAK {
        $!top = self.rewrite-target( TOP , :unique);
        self.process-pod;
    }

    method register-toc(:$level!, :$text!, Bool :$is-title = False --> Str) {
        @!counters[$level - 1]++;
        @!counters.splice($level);
        my $counter = @!counters>>.Str.join: '_';
        my $target = self.rewrite-target($text, :!unique ) ;
        @!toc.push: %( :$level, :$text, :$target, :$is-title, :$counter );
        $target
    }
    method render-toc( --> Str ) {
        $!engine.rendition('toc', %( :toc( [@!toc.grep( { !( .<is-title>) } )] )  ));
    }
    method register-index(Str $text, @entries, Bool $is-header --> Str) {
        my $target;
        if $is-header {
            $target = @.toc[ * - 1 ]<target>
            # the last header to be added to the toc will have the url we want
        }
        else {
            # there must be something in either text or entries[0] to get here
            $target = @entries ?? @entries.join('-') !! $text;
            $target = self.rewrite-target($target, :unique)
        }
        my $place = @.toc ?? @.toc[ * - 1]<text> !! FRONT-MATTER;
        if @entries {
            for @entries {
                %.index{ .[0] } = Array unless %.index{ .[0] }:exists;
                if .elems > 1 { %.index{ .[0] }.push: %(:$target, :place( .[1] )) }
                else { %.index{ .[0] }.push: %(:$target, :$place ) }
            }
        }
        else { # if no entries, then there must be $text to get here
            %.index{$text} = Array unless %.index{$text}:exists;
            %.index{$text}.push: %(:$target, :$place);
        }
        $target
    }
    method render-index(-->Str) {
        return '' unless +%!index.keys; #No render without any keys
        $!engine.rendition( 'index', %( :index([gather for %!index.sort {  take %(:text(.key), :refs( [.value.sort] )) } ])  )  )
    }
    method register-link(Str $entry, Str $target is copy --> Str) {
        my $lable= $entry ?? $entry !! $target;
        $target = self.rewrite-target($target, :!unique);
        @!links.push: %( :$lable, :$target);
        $target
    }
    method register-footnote(:$text! --> Hash ) {
        my $fnNumber = +@!footnotes + 1;
        my $fnTarget = self.rewrite-target("fn$fnNumber",:unique) ;
        my $retTarget = self.rewrite-target("fnret$fnNumber",:unique);
        @!footnotes.push: %( :$text, :$retTarget, :$fnNumber, :$fnTarget  );
        (:$fnTarget, :$fnNumber, :$retTarget).hash
    }
    method render-footnotes(--> Str){
        return '' unless @!footnotes; # no rendering of code if no footnotes
        $!engine.rendition('footnotes', %( :notes( @!footnotes )  ) )
    }
    method register-meta( :$name, :$value ) {
        push @!metalist: %( :$name, :$value )
    }
    method render-meta {
        return '' unless @!metalist;
        $!engine.rendition('meta', %( :meta( @!metalist )  ))
    }
    method process-pod {
        state $processed =0;
        say "pod-tree is:" ~ $!pod-tree.perl if $.debug;
        print "Processing pod #{++$processed } for $.name " if $!verbose;
        my $time = now;
        $!pod-body = [~] $!pod-tree>>.&handle( 0, self );
        self.filter-links;
        $!when-rendered = now;
        say " in " ~ DateTime.new($!when-rendered - $time ).second.fmt("%.2f") ~ "s" if $!verbose;
    }

    method rendered-at( -->Str ) {
        DateTime.new($!when-rendered).truncated-to('seconds').Str;
    }
    method filter-links {
        # links have to be collected from the whole source before testing
        # remove from the links list all those that match an internal target
        # links to internal targets are specified with 1st char # in target
        # targets in index are stored without #
        my Set $internal .= new: gather for %.index.values -> @items { take .<target> for @items }
        @!links = gather for @!links {
            next if .<target> ~~ m/^ '#' $<tgt>=(.+) $ / and $internal{ $<tgt> }; #remove
            take %(:source($!name), :target( .<target> ), :lable( .<lable> ) )
        }
    }

    method rewrite-target(Str $candidate-name is copy, :$unique --> Str ) {
        # when indexing a unique target is needed even when same entry is repeated
        # when a Heading is a target, the reference must come from the name
        $candidate-name = $candidate-name.lc.subst(/\s+/,'_',:g);
        $candidate-name = ($!collection-unique ?? $!name.subst([\/], '_') !! '') ~ $candidate-name;
        if $unique {
            $candidate-name ~= '_0' if $candidate-name (<) $!targets;
            ++$candidate-name while $!targets{$candidate-name}; # will continue to loop until a unique name is found
        }
        $!targets{ $candidate-name }++; # now add to targets, no effect if not unique
        $candidate-name
    }

    method completion(Int $in-level, Str $key, %params --> Str) {
        my Str $rv = '';
        # first deal with any existing defn list when next not a defn
        my $top-level = @.itemlist.elems;
        while $top-level > $in-level {
            if $top-level > 1 {
                @.itemlist[$top-level - 2][0] = '' unless @.itemlist[$top-level - 2][0]:exists;
                @.itemlist[$top-level - 2][* - 1] ~= $!engine.rendition('list', %( :items( @.itemlist.pop )  ));
                note "At $?LINE rendering with template ｢list｣ list level $in-level" if $!debug;
            }
            else {
                $rv ~= $!engine.rendition('list', %( :items( @.itemlist.pop )  ));
                note "At $?LINE rendering with template ｢list｣ list level $in-level" if $!debug;
                note "At $?LINE rv is $rv" if $!debug;
            }
            $top-level = @.itemlist.elems
        }
        note "At $?LINE rendering with template ｢$key｣ list level $in-level" if $!debug;
        $rv ~= $!engine.rendition($key, %params);
        note "At $?LINE rv is $rv" if $!debug;
        $rv
    }

    method highlight( Str $st --> Str ) {
        &!highlighter( $st )
    }

    method source-wrap( :$name = $!name --> Str ) {
        $!engine.rendition('source-wrap', {
            :$name,
            :orig-name($!name),
            :title($!title),
            :subtitle($!subtitle),
            :metadata(self.render-meta),
            :toc( self.render-toc ),
            :index( self.render-index),
            :footnotes( self.render-footnotes ),
            :body( $!pod-body ),
            :path( $!path ),
            :time( DateTime.new($!when-rendered).utc.truncated-to('seconds').Str )
        } )
    }

    my enum Context <None Index Heading HTML Raw Output>;

    multi sub recurse-until-str(Str:D $s){ $s } # strip out formating code and links
    multi sub recurse-until-str(Pod::Block $n){ $n.contents>>.&recurse-until-str().join }

    #| Multi for handling different types of Pod blocks.

    multi sub handle (Pod::Block::Code $node, Int $in-level, PodCache::Processed $pf, Context $context? = None  --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl }" if $pf.debug;
        my $addClass = $node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '';
        # first completion is to flush a retained list before the contents of the block are processed
        my $retained-list = $pf.completion($in-level,'zero', %() );
        my $contents =  [~] $node.contents>>.&handle($in-level, $pf );
        with $pf.highlighter {
            $retained-list ~ $pf.highlight( $contents )
        }
        else {
            $retained-list ~ $pf.completion($in-level, 'block-code', %( :$addClass, :$contents ) )
        }
    }

    multi sub handle (Pod::Block::Comment $node, Int $in-level, PodCache::Processed $pf, Context $context? = None  --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl }" if $pf.debug;
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level, 'zero', %( :contents([~] $node.contents>>.&handle($in-level, $pf )) ))
    }

    multi sub handle (Pod::Block::Declarator $node, Int $in-level, PodCache::Processed $pf, Context $context? = None  --> Str )  {
        note "At $?LINE node is ", $node.WHAT.perl if $pf.debug;
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level, 'notimplemented', %( :contents([~] $node.contents>>.&handle($in-level, $pf )) ))
    }

    multi sub handle (Pod::Block::Named $node, Int $in-level, PodCache::Processed $pf, Context $context? = None  --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with name { $node.name // 'na' }" if $pf.debug;
        my $target = $pf.register-toc( :1level, :text( $node.name.tclc ) );
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level, 'named', %(
            :name($node.name.tclc),
            :$target,
            :1level,
            :contents( [~] $node.contents>>.&handle($in-level, $pf )),
            :top( $pf.top )
        ))
    }

    multi sub handle (Pod::Block::Named $node where $node.name.lc eq 'pod', Int $in-level, PodCache::Processed $pf, Context $context? = None  --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with name { $node.name // 'na' }" if $pf.debug;
        my $name = $pf.top eq TOP ?? TOP !! 'pod' ; # TOP, until TITLE changes it. Will fail if multiple pod without TITLE
        my $contents =
        $pf.completion($in-level, 'section', %(
            :$name,
            :contents( [~] $node.contents>>.&handle($in-level, $pf )),
            :tail( $pf.completion(0, 'zero', %() ) )
        ))
    }

    multi sub handle (Pod::Block::Named $node where $node.name eq 'TITLE', Int $in-level, PodCache::Processed $pf, Context $context? = None --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with name { $node.name // 'na' }" if $pf.debug;
        my $addClass = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '');
        my $text = $pf.title = $node.contents[0].contents[0].Str;
        $pf.top = $pf.register-toc(:1level, :$text, :is-title );
        my $target = $pf.top;
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level, 'title', %( :$addClass, :$target, :$text  ) )
    }

    multi sub handle (Pod::Block::Named $node where $node.name eq 'SUBTITLE', Int $in-level, PodCache::Processed $pf, Context $context? = None --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with name { $node.name // 'na' }" if $pf.debug;
        my $addClass = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '');
        my $contents = $pf.subtitle = [~] $node.contents>>.&handle($in-level,$pf, None);
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level, 'subtitle', %( :$addClass, :$contents  ) )
    }

    multi sub handle (Pod::Block::Named $node where $node.name ~~ any(<VERSION DESCRIPTION AUTHOR SUMMARY>),
        Int $in-level, PodCache::Processed $pf, Context $context? = None --> Str ) {
        note "At $?LINE node is { $node.WHAT.perl } with name { $node.name // 'na' }" if $pf.debug;
        $pf.register-meta(:name($node.name.lc), :value($node.contents[0].contents[0].Str));
        $pf.completion($in-level,'zero', %() )  # make sure any list is correctly ended.
    }

    multi sub handle (Pod::Block::Named $node where $node.name eq 'Html' , Int $in-level, PodCache::Processed $pf, Context $context? = None --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with name { $node.name // 'na' }" if $pf.debug;
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level, 'raw', %( :contents( [~] $node.contents>>.&handle($in-level, $pf, HTML) )  ) )
    }

    multi sub handle (Pod::Block::Named $node where .name eq 'output', Int $in-level, PodCache::Processed $pf, Context $context? = None  --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with name { $node.name // 'na' }" if $pf.debug;
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level, 'output', %( :contents( [~] $node.contents>>.&handle($in-level, $pf, Output) )  ) )
    }

    multi sub handle (Pod::Block::Named $node where .name eq 'Raw', Int $in-level, PodCache::Processed $pf, Context $context? = None  --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with name { $node.name // 'na' }" if $pf.debug;
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level, 'raw', %( :contents( [~] $node.contents>>.&handle($in-level, $pf, Output) )  ) )
    }

    multi sub handle (Pod::Block::Para $node, Int $in-level, PodCache::Processed $pf, Context $context where * == Output  --> Str )  {
        note "At $?LINE node is ", $node.WHAT.perl if $pf.debug;
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level, 'raw', %( :contents( [~] $node.contents».&handle($in-level, $pf ) )  ) )
    }

    multi sub handle (Pod::Block::Para $node, Int $in-level, PodCache::Processed $pf , Context $context? = None --> Str )  {
        note "At $?LINE node is ", $node.WHAT.perl if $pf.debug;
        my $addClass = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '');
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level, 'para', %( :$addClass, :contents( [~] $node.contents>>.&handle($in-level, $pf, $context ) )  ) )
    }

    multi sub handle (Pod::Block::Para $node, Int $in-level, PodCache::Processed $pf, Context $context where * != None  --> Str )  {
        note "At $?LINE node is ", $node.WHAT.perl if $pf.debug;
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level, 'raw', %( :contents( [~] $node.contents>>.&handle($in-level, $pf, $context) )  ) )
    }

    multi sub handle (Pod::Block::Table $node, Int $in-level, PodCache::Processed $pf  --> Str )  {
        note "At $?LINE node is ", $node.WHAT.perl if $pf.debug;
        my $addClass = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '');
        my @headers = gather for $node.headers { take .&handle($in-level, $pf ) };
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level,  'table', %(
                :$addClass,
                :caption( $node.caption ?? $node.caption.&handle($in-level, $pf ) !! ''),
                :headers( +@headers ?? %( :cells( @headers ) ) !! Nil ),
                :rows( [ gather for $node.contents -> @r {
                    take %( :cells( [ gather for @r { take .&handle($in-level, $pf ) } ] )  )
                } ] ),
            ) )
    }

    multi sub handle (Pod::Defn $node, Int $in-level, PodCache::Processed $pf, Context $context = None --> Str )  {
        note "At $?LINE node is ", $node.WHAT.perl if $pf.debug;
        my $addClass = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '');
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level, 'defn', %( :$addClass, :term($node.term), :contents( [~] $node.contents>>.&handle($in-level, $pf, $context ) )  ) )
    }

    multi sub handle (Pod::Heading $node, Int $in-level, PodCache::Processed $pf --> Str )  {
        note "At $?LINE node is ", $node.WHAT.perl if $pf.debug;
        my $retained-list = $pf.completion($in-level,'zero', %() ); # process before contents
        my $addClass = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '');
        my $level = $node.level;
        my $target = $pf.register-toc( :$level, :text( recurse-until-str($node).join ) ); # must register toc before processing content!!
        my $text = [~] $node.contents>>.&handle($in-level, $pf, Heading);
        $retained-list ~ $pf.completion($in-level, 'heading', {
            :$level,
            :$text, # we want all the formatting here
            :$addClass,
            :$target,
            :top( $pf.top )
        })
    }

    multi sub handle (Pod::Item $node, Int $in-level is copy, PodCache::Processed $pf --> Str  )  {
        note "At $?LINE node is ", $node.WHAT.perl if $pf.debug;
        my $addClass = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '');
        my $level = $node.level - 1;
        while $level < $in-level {
            --$in-level;
            $pf.itemlist[$in-level]  ~= $pf.engine.rendition('list', %( :items( $pf.itemlist.pop ) ) )
        }
        while $level >= $in-level {
            $pf.itemlist[$in-level] = []  unless $pf.itemlist[$in-level]:exists;
            ++$in-level
        }
        $pf.itemlist[$in-level - 1 ].push: $pf.engine.rendition('item', %( :$addClass, :contents([~] $node.contents>>.&handle($in-level, $pf ) )  ) );
        return '' # explicitly return an empty string because callers expecting a Str
    }

    multi sub handle (Pod::Raw $node, Int $in-level, PodCache::Processed $pf --> Str )  {
        note "At $?LINE node is ", $node.WHAT.perl if $pf.debug;
        $pf.completion($in-level,'zero', %() ) ~ $pf.engine.rendition('raw', %( :contents( [~] $node.contents>>.&handle($in-level, $pf ) )  ) )
    }

    multi sub handle (Str $node, Int $in-level, PodCache::Processed $pf, Context $context? = None --> Str )  {
        note "At $?LINE node is ", $node.WHAT.perl if $pf.debug;
        $pf.completion($in-level,'zero', %() ) ~ $pf.engine.rendition('escaped', %( :contents(~$node) ))
    }

    multi sub handle (Str $node, Int $in-level, PodCache::Processed $pf, Context $context where * == HTML --> Str )  {
        note "At $?LINE node is ", $node.WHAT.perl if $pf.debug;
        $pf.completion($in-level,'zero', %() ) ~ $pf.engine.rendition('raw', %( :contents(~$node) ))
    }

    multi sub handle (Nil)  {
        die 'Nil';
    }

    multi sub handle (Pod::Config $node, Int $in-level, PodCache::Processed $pf  --> Str )  {
        note "At $?LINE node is ", $node.WHAT.perl if $pf.debug;
        $pf.completion($in-level,'zero', %() ) ~ $pf.completion($in-level, 'comment',%( :contents($node.type ~ '=' ~ $node.config.perl)  ) )
    }

    multi sub handle (Pod::FormattingCode $node, Int $in-level, PodCache::Processed $pf, Context $context where * == Raw   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        $pf.completion($in-level, 'raw', %( :contents( [~] $node.contents>>.&handle($in-level, $pf, $context) )  ) )
    }

    multi sub handle (Pod::FormattingCode $node where .type ~~ none(<B C E Z I X N L P R T K U V>), Int $in-level, PodCache::Processed $pf, Context $context where * == None   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        $pf.completion($in-level, 'escaped', %( :contents( $node.type ~ '<' ~ [~] $node.contents>>.&handle($in-level, $pf, $context) ~ '>' )  ) )
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'B', Int $in-level, PodCache::Processed $pf, Context $context = None   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        my $addClass = $node.config && $node.config<class> ?? $node.config<class> !! '';
        $pf.completion($in-level, 'format-b',%( :$addClass, :contents( [~] $node.contents>>.&handle($in-level, $pf, $context) )  ))
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'C', Int $in-level, PodCache::Processed $pf, Context $context? = None   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        my $addClass = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '');
        $pf.completion($in-level, 'format-c', %( :$addClass, :contents([~] $node.contents>>.&handle($in-level, $pf, $context ) )  ) )
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'C', Int $in-level, PodCache::Processed $pf, Context $context where * ~~ Index   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        $pf.completion($in-level, 'format-c-index', %( :contents( [~] $node.contents>>.&handle($in-level, $pf ) ) ))
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'E', Int $in-level, PodCache::Processed $pf, Context $context? = None   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        $pf.completion($in-level, 'raw', %( :contents( [~] $node.meta.map({ when Int { "&#$_;" }; when Str { "&$_;" }; $_ }) )  ) )
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'Z', Int $in-level, PodCache::Processed $pf, $context = None   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        $pf.completion($in-level, 'zero',%( :contents([~] $node.contents>>.&handle($in-level, $pf, $context))  ) )
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'I', Int $in-level, PodCache::Processed $pf, Context $context = None   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        my $addClass = $node.config && $node.config<class> ?? $node.config<class> !! '';
        $pf.completion($in-level, 'format-i',%( :$addClass, :contents( [~] $node.contents>>.&handle($in-level, $pf, $context) )  ))
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'X', Int $in-level, PodCache::Processed $pf, Context $context = None   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        my $addClass = $node.config && $node.config<class> ?? $node.config<class> !! '';
        my Bool $header = $context ~~ Heading;
        my $text = [~] $node.contents>>.&handle($in-level, $pf, $context);
        return ' ' unless $text or +$node.meta; # ignore if there is nothing that can be an entry
        my $target = $pf.register-index( recurse-until-str($node).join , $node.meta, $header );
        $pf.completion($in-level, 'format-x',%( :$addClass, :$text, :$target,  :$header  ) )
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'N', Int $in-level, PodCache::Processed $pf, Context $context = None --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        my $text = [~] $node.contents>>.&handle($in-level, $pf,$context);
        $pf.completion($in-level, 'format-n', $pf.register-footnote(:$text) )
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'L', Int $in-level, PodCache::Processed $pf, Context $context = None   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        my $addClass = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '');
        my $contents = [~] $node.contents>>.&handle($in-level, $pf, $context);
        my $target = $node.meta eqv [] | [""] ?? $contents !! $node.meta[0];
        $target = $pf.register-link( recurse-until-str($node).join, $target );
        # link handling needed here to deal with local links in global-link context
        $pf.completion($in-level, 'format-l', %( :$target, :$addClass, :contents([~] $node.contents>>.&handle($in-level, $pf, $context ) )  ) )
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'R', Int $in-level, PodCache::Processed $pf, Context $context = None   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        my $addClass = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '');
        $pf.completion($in-level, 'format-r', %( :$addClass, :contents([~] $node.contents>>.&handle($in-level, $pf, $context ) )  ) )
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'T', Int $in-level, PodCache::Processed $pf, Context $context = None   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        my $addClass = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '');
        $pf.completion($in-level, 'format-t', %( :$addClass, :contents([~] $node.contents>>.&handle($in-level, $pf, $context ) )  ) )
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'K', Int $in-level, PodCache::Processed $pf, Context $context? = None   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        my $addClass = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '');
        $pf.completion($in-level, 'format-k', %( :$addClass, :contents([~] $node.contents>>.&handle($in-level, $pf, $context ) )  ) )
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'U', Int $in-level, PodCache::Processed $pf, Context $context = None   --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        my $addClass = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '');
        $pf.completion($in-level, 'format-u', %( :$addClass, :contents([~] $node.contents>>.&handle($in-level, $pf, $context ) )  ) )
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'V', Int $in-level, PodCache::Processed $pf, Context $context = None  --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        $pf.completion($in-level, 'escaped', %( :contents([~] $node.contents>>.&handle($in-level, $pf, $context ) )  ) )
    }

    multi sub handle (Pod::FormattingCode $node where .type eq 'P', Int $in-level, PodCache::Processed $pf, Context $context = None  --> Str )  {
        note "At $?LINE node is { $node.WHAT.perl } with type { $node.type // 'na' }" if $pf.debug;
        my Str $link-contents = [~] $node.contents>>.&handle($in-level, $pf, $context);
        my $link = ($node.meta eqv [] | [""] ?? $link-contents !! $node.meta).Str;
        my URI $uri .= new($link);
        my Str $contents;
        given $uri.scheme {
            when 'http' | 'https' {
                my LibCurl::Easy $curl .= new( :URL($link), :followlocation, :verbose($pf.verbose) );
                CATCH {
                    when X::LibCurl {
                        $contents = "Link ｢$link｣ caused LibCurl Exception, response code ｢{$curl.response-code}｣ with error ｢{$curl.error}｣";
                        note $contents if $pf.verbose;
                    }
                }
                $contents = $curl.perform.content;
            }
            when 'file' | '' {
                if ($uri.path).IO ~~ :f {
                    $contents = ($uri.path).IO.slurp;
                }
                else {
                    $contents = "No file found at ｢$link｣";
                    note $contents if $pf.verbose;
                }
            }
            default {
                $contents = "Scheme ｢$_｣ is not implemented for P<$link-contents>"
            }
        } # Catch will resume here
        my $html = $contents ~~ m/ '<html' (.+) $ /;
        $contents = ('<html' ~ $/[0]) if $html;
        $pf.completion($in-level, 'format-p', %( :$contents, :$html ))
    }

    =begin takeout
            In S26:
            A second kind of link—the P<> or placement link—works in the opposite direction. Instead of directing focus out to another document, it allows you to assimilate the contents of another document into your own.
        In other words, the P<> formatting code takes a URI and (where possible) inserts the contents of the corresponding document inline in place of the code itself.
        P<> codes are handy for breaking out standard elements of your documentation set into reusable components that can then be incorporated directly into multiple documents. For example:
        COPYRIGHT
        P<file:/shared/docs/std_copyright.pod>
        DISCLAIMER
        P<http://www.MegaGigaTeraPetaCorp.com/std/disclaimer.txt>
        might produce:
        Copyright
        This document is copyright (c) MegaGigaTeraPetaCorp, 2006. All rights reserved.
        Disclaimer
        ABSOLUTELY NO WARRANTY IS IMPLIED. NOT EVEN OF ANY KIND. WE HAVE SOLD YOU THIS SOFTWARE WITH NO HINT OF A SUGGESTION THAT IT IS EITHER USEFUL OR USABLE. AS FOR GUARANTEES OF CORRECTNESS...DON'T MAKE US LAUGH! AT SOME TIME IN THE FUTURE WE MIGHT DEIGN TO SELL YOU UPGRADES THAT PURPORT TO ADDRESS SOME OF THE APPLICATION'S MANY DEFICIENCIES, BUT NO PROMISES THERE EITHER. WE HAVE MORE LAWYERS ON STAFF THAN YOU HAVE TOTAL EMPLOYEES, SO DON'T EVEN *THINK* ABOUT SUING US. HAVE A NICE DAY.
        If a renderer cannot find or access the external data source for a placement link, it must issue a warning and render the URI directly in some form, possibly as an outwards link. For example:
        Copyright
        See: std_copyright.pod
        Disclaimer
        See: http://www.MegaGigaTeraPetaCorp.com/std/disclaimer.txt

        You can use any of the following URI forms (see Links) in a placement link:
            http: and https:
            file:
            man:
            doc:
            toc:

        The toc: form is a special pseudo-scheme that inserts a table of contents in place of the P<> code. After the colon, list the block types that you wish to include in the table of contents. For example, to place a table of contents listing only top- and second-level headings:

        P<toc: head1 head2>

        To place a table of contents that lists the top four levels of headings, as well as any tables:

        P<toc: head1 head2 head3 head4 table>

        To place a table of diagrams (assuming a user-defined Diagram block):

        P<toc: Diagram>

        Note also that, for P<toc:...>, all semantic blocks are treated as equivalent to head1 headings, and the =item1/=item equivalence is preserved.

        A document may have as many P<toc:...> placements as necessary.

        # NYI
        # multi sub handle (Pod::Block::Ambient $node) {
        #   $node.perl.say;
        #   $node.contents>>.&handle;
        # }
    =end takeout
