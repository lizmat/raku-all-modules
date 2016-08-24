unit class Pod::To::BigPage;

our $html-header;
our $html-before-content;
our $html-after-content;

my @toc;
my %register;

constant NL = "\n";

class TOC-Counter is export { 
    has Int @!counters is default(0);
    method Str () { @!counters>>.Str.join: '.' }
    method inc ($level) { 
        @!counters[$level - 1]++;
        @!counters.splice($level);
#       dd @!counters;
        self
    }
    method set-part-number ($part-number) { 
        @!counters[0] = $part-number; 
        self 
    }
}

sub setup () is export {
    $html-header = q:to/EOH/;
        <title>Untitled</title>
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
        <style type="text/css">
            body { margin-left: 4em; margin-right: 4em; }
            p {
                text-rendering: optimizeLegibility;
                font-feature-settings: "kern";
                -webkit-font-feature-settings: "kern";
                -moz-font-feature-settings: "kern";
                -moz-font-feature-settings: "kern=1";
                font-kerning: normal;
                text-align: justify;
            }
            div.pod-content { padding-left: 20em; }
            div.pod-body { width: 60em }
            div.marginale { float: right; margin-right: -4em; width: 18em; font-size: 66%; text-align: left; }
            span.filename { font-family: monospace; font-stretch: condensed; }
            h1.title { font-size: 200%; }
            h1 { font-size: 160%; }
            h2 { font-size: 140%; }
            h3 { font-size: 120%; }
            h4 { font-size: 100%; }
            h5 { font-size: 100%; }
            h6 { font-size: 100%; }
            h7 { font-size: 100%; }
            pre { padding-left: 2em; }
            ul.toc { list-style-type: none; padding-left: 0; margin-left: 0 }
            ul.toc ul { list-style-type: none; }
            ul.toc ul { margin-left: 0; padding-left: 1em; }
            ul.toc li { margin-left: 0; padding-left: 0em; }
            ul.toc li.toc-level-1 { padding-left: 1em; }
            ul.toc li.toc-level-2 { padding-left: 1em; }
            ul.toc li.toc-level-3 { padding-left: 1em; }
            ul.toc li.toc-level-4 { padding-left: 1em; }
            ul.toc li.toc-level-5 { padding-left: 1em; }
            ul.toc li.toc-level-6 { padding-left: 1em; }
            ul.toc li.toc-level-7 { padding-left: 1em; }
            ul.toc li.toc-level-8 { padding-left: 1em; }
            ul.toc li.toc-level-9 { padding-left: 1em; }
            ul.toc li.toc-level-10{ padding-left: 1em; }
            #left-side-menu { 
                width: 20em; margin-left: -22em; 
                float: left; 
                position: fixed;
                top: 0;
                overflow: scroll;
                height: 100%;
                padding: 0;
                white-space: nowrap;
            }
            #left-side-menu-header { 
                transform: rotate(90deg); 
                transform-origin: left bottom 0;
                z-index: 1;
                position: fixed;
                float: left;
                top: 0;
                margin-left: -23.5em;
            }
            #left-side-menu-header span.selection { padding-left: 1em; padding-right: 1em; }
            .code { font-family: monospace; background-color: #f9f9f9; }
            ul.numbered {
                list-style: none;
            }
            span.numbered-prefix {
                float: left;
            }
            span.numbered-prefix::after {
                content: ")\00a0";
            }

            @media print {
                div.pod-content { padding-left: 0; width: 100% }
                div.pod-body { width: 90%; }
                #left-side-menu { 
                    width: unset;
                    margin-left: unset; 
                    float: unset; 
                    position: unset;
                    top: unset;
                    overflow: unset;
                    height: unset;
                    padding: unset;
                    white-space: unset;
                }
                div.left-side-menu-header, #index { display: none; }
            }
            </style>
        <link href="pod-to-bigpage.css" rel="stylesheet" type="text/css" />
        EOH
    $html-before-content = '';
    $html-after-content = '';
}

sub set-foreign-toc (\toc) is export {
    @toc := toc;
}

sub set-foreign-index (\index) is export {
    %register := index;
}

sub register-index-entry(@meta, @content, :$pod-name!) {
    state $lock = Lock.new;
    state $global-index-counter;
    my $id;
    $lock.protect: {
        $id = (++$global-index-counter).Str;
        %register{.Str}.push($id) for @meta;
    }
    $id
}

sub register-toc-entry($level, $text, $part-toc-counter, :$hide) {
    state $lock = Lock.new;
    my $clone;
    $lock.protect: {
        $part-toc-counter.inc($level+1);
        $clone = $part-toc-counter.Str;
        @toc.push: $clone => $text => $level unless $hide;
    }
    $clone
}

sub compose-toc (:$toc = @toc) is export {
    '<div id="toc"><ul class="toc">' ~ NL ~
    @toc\
        .sort({$_.key.subst(/(\d+)/, -> $/ { 0 ~ $0.chars.chr ~ $0 }, :g)})\
        .map({ Q:c (<a href="#t{$_.key}"><li class="toc-level toc-level-{$_.value.value}"><span class="toc-number">{$_.key}</span> {$_.value.key}</li></a>) }).join(NL) ~
    '</ul></div>'
}

sub compose-index (:$register = %register) is export {
    my @dupes = $register.grep(*.value.elems > 1);
    note "found duplicate index entry {.key} at {.value.map: {'#i' ~ .Str}}" for @dupes;
    '<div id="index"><ul class="index">' ~ NL ~
    $register.sort(*.key.lc).map({ 
        '<li>' ~ .key.Str.subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g) ~ '&emsp;' ~ .value.map({ '<a href="#i' ~ .Str ~ '">' ~ .Str ~ '</a>' }) ~ '</li>' 
    }) ~
    '</ul></div>'
}

sub compose-left-side-menu () is export {
    '<div id="left-side-menu-header"><a href="#toc"><span class="selection">TOC</span></a><a href="#index"><span class="selection">Index</span></a></div><div id="left-side-menu">' ~
    compose-toc() ~ compose-index() ~
    '</div>'
}

sub compose-before-content () is export {
    '<?xml version="1.0" encoding="utf-8" ?>' ~ NL ~
    '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' ~ NL ~
    '<html xmlns="http://www.w3.org/1999/xhtml">' ~ NL ~
    '<head>' ~ NL ~
    $html-header ~ NL ~
    '</head>' ~ NL ~
    qq{<body>$html-before-content\n  <div class="pod-content">} ~ NL
}

sub compose-after-content () is export {
    qq{  </div>$html-after-content\n</body>} ~
    '</html>'
}

method render ($pod:) is export {
    setup();
    
    compose-before-content ~
    await do start { handle($_) } for $pod.flat ~
    compose-toc() ~ compose-after-content
}

my enum Context ( None => 0, Index => 1 , Heading => 2, HTML => 3, Raw => 4, Output => 5);
my %list-item-counter is default(0);
my $last-part-number= -1;

# my proto sub handle ($node, Context $context = None, :$pod-name?, :$part-number?, :$toc-counter?, :%part-config?) is export {
#     {*}
# }

multi sub handle (Pod::Block::Code $node, :$pod-name?, :$part-number?, :$toc-counter?, :%part-config?) is export {
    my $additional-class = $node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '';
    Q:c (<pre class="code{$additional-class}">{$node.contents>>.&handle().subst('&', '&amp;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)}</pre>) ~ NL;
}

multi sub handle (Pod::Block::Comment $node, :$pod-name?, :$part-number?, :$toc-counter?, :%part-config?) is export {
    $node.contents>>.&handle();
}

multi sub handle (Pod::Block::Declarator $node, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    $node.contents>>.&handle();
}

multi sub handle (Pod::Block::Named $node, :$pod-name?, :$part-number?, :$toc-counter?, :%part-config) is export {
    $node.contents>>.&handle(:$pod-name, :$part-number, :$toc-counter, :%part-config);
}

multi sub handle (Pod::Block::Named $node where $node.name eq 'TITLE', :$pod-name?, :$part-number?, :$toc-counter, :%part-config) is export {
    my $additional-class = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '').subst('"', '&quot;');
    my $text = $node.contents[0].contents[0].Str;
    my $anchor = register-toc-entry(0, $text, $toc-counter);
    Q:c (<a name="t{$anchor}"><h1 class="title{$additional-class}">{$anchor} {$text}</h1></a>) 
}

multi sub handle (Pod::Block::Named $node where $node.name eq 'SUBTITLE', :$pod-name?, :$part-number?, :$toc-counter?, :%part-config) is export {
    my $additional-class = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '').subst('"', '&quot;');
    my $text = $node.contents[0].contents[0].Str;
    Q:c (<p class="subtitle{$additional-class}">{$text}</p>) 
}

multi sub handle (Pod::Block::Named $node where $node.name eq 'Html', :$pod-name?, :$part-number?, :$toc-counter?, :%part-config) is export {
    $node.contents>>.&handle(HTML) ~ NL;
}

multi sub handle (Pod::Block::Named $node where .name eq 'output', :$pod-name?, :$part-number?, :$toc-counter?, :%part-config) is export {
    '<pre class="pod-output">' ~ $node.contents>>.&handle(Output).join(NL) ~ '</pre>' ~ NL
}

multi sub handle (Pod::Block::Para $node, $context where * == Output, :$pod-name?, :$part-number?, :$toc-counter?, :%part-config) is export {
    $node.contents».&handle().join
}

multi sub handle (Pod::Block::Para $node, $context = None, :$pod-name?, :$part-number?, :$toc-counter?, :%part-config) is export {
    my $class = $node.config && $node.config<class> ?? ' class = "' ~ $node.config<class>.subst('"', '&quot;') ~ '"' !! '';
    "<p$class>" ~ $node.contents>>.&handle($context, :$pod-name, :$part-number).join('') ~ '</p>' ~ NL;
}

multi sub handle (Pod::Block::Para $node, $context where * != None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    $node.contents>>.&handle($context, :$pod-name).join('');
}

multi sub handle (Pod::Block::Table $node, :$pod-name?, :$part-number?, :$toc-counter?, :%part-config?) is export {
    my $class = $node.config && $node.config<class> ?? ' class = "' ~ $node.config<class>.subst('"', '&quot;') ~ '"' !! '';
    "<table$class>" ~ NL ~
    ($node.caption ?? '<caption>' ~ $node.caption.&handle() ~ '</caption>>' !! '' ) ~
    ($node.headers ?? '<tr>' ~ do for $node.headers -> $cell { '<th>' ~ $cell.&handle() ~ '</th>' } ~ '</tr>' ~ NL !! '' ) ~
    do for $node.contents -> @row { 
        '<tr>' ~ do for @row -> $cell { '<td>' ~ $cell.&handle() ~ '</td>' } ~ '</tr>' ~ NL 
    } ~ 
    '</table>'
}

multi sub handle (Pod::Config $node, :$pod-name?, :$part-number?, :$toc-counter?, :%part-config) is export {
    %part-config<<{$node.type.Str}>> = $node.config;
    '<!-- ' ~ $node.type ~ '=' ~ $node.config.perl ~ '-->'
}

multi sub handle (Pod::FormattingCode $node, $context where * == Raw, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    $node.contents>>.&handle($context).join('');
}

multi sub handle (Pod::FormattingCode $node where .type eq 'B', $context = None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    my $class = $node.config && $node.config<class> ?? ' class = "' ~ $node.config<class>.subst('"', '&quot;') ~ '"' !! '';
    "<b$class>" ~ $node.contents>>.&handle($context) ~ '</b>';
}

multi sub handle (Pod::FormattingCode $node where .type eq 'C', $context = None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    my $additional-class = $node.config && $node.config<class> ?? ' ' ~ $node.config<class>.subst('"', '&quot;') !! '';
    Q:c (<span class="code{$additional-class}">{$node.contents>>.&handle($context).join('')}</span>)
}

multi sub handle (Pod::FormattingCode $node where .type eq 'C', $context where * ~~ Index = None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    'C<' ~ $node.contents>>.&handle().join('') ~ '>';
}

multi sub handle (Pod::FormattingCode $node where .type eq 'E', $context = None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    $node.meta.fmt('&%s;').join 
}

multi sub handle (Pod::FormattingCode $node where .type eq 'F', $context = None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    my $extraclass = $node.config && $node.config<class> ?? " " ~ $node.config<class>.subst('"', '&quot;') !! '';
    Q:c (<span class="filename{$extraclass}">{$node.contents>>.&handle($context)}</span>)
}

sub rewrite-link($link-target is copy, :$part-number!){
    given $link-target {
        when .starts-with( any(<http:// https:// irc://>) ) { succeed }
        when .starts-with('#')           { $link-target = '#' ~ $part-number ~ '-' ~ $link-target.substr(1) }
        when .starts-with(any('a'..'z')) { $link-target = "/routine/$link-target"; proceed }
        when .starts-with(any('A'..'Z')) { $link-target = "/type/$link-target"; proceed }
        when .starts-with('/')           { 
            my @parts = $link-target.split('#');
            @parts[0] = '#' ~ @parts[0].subst('/', '_', :g) ~ '.pod6';
            $link-target = @parts.join('-');
        }
    }
    $link-target
}

multi sub handle (Pod::FormattingCode $node where .type eq 'L', $context = None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    my $class = $node.config && $node.config<class> ?? ' class = "' ~ $node.config<class>.subst('"', '&quot;') ~ '"' !! '';
    my $content = $node.contents>>.&handle($context);
    my $link-target = $node.meta eqv [] | [""] ?? $content !! $node.meta;

    $link-target.=&rewrite-link(:$part-number);

    Q:c (<a href="{$link-target.subst('&', '&amp;', :g).subst('"', '&quot;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g)}"{$class}>{$content}</a>)
}

multi sub handle (Pod::FormattingCode $node where .type eq 'I', $context = None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    my $class = $node.config && $node.config<class> ?? ' class = "' ~ $node.config<class>.subst('"', '&quot;') ~ '"' !! '';
    "<i$class>" ~ $node.contents>>.&handle($context) ~ '</i>';
}

multi sub handle (Pod::FormattingCode $node where .type eq 'N', $context = None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    my $additional-class = $node.config && $node.config<class> ?? ' ' ~ $node.config<class>.subst('"', '&quot;') !! '';
    Q:c (<div class="marginale{$additional-class}">{$node.contents>>.&handle($context)}</div>);
}

multi sub handle (Pod::FormattingCode $node where .type eq 'P', $context = None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    my $content = $node.contents>>.&handle($context).Str;
    my $link = $node.meta eqv [] | [""] ?? $content !! $node.meta;
    
    use LWP::Simple;
    my @url = LWP::Simple.parse_url($link);
    my $doc;
    given @url[0] {
        when 'http' | 'https' { 
            $doc = LWP::Simple.get($link);
        }
        when 'file' {
            $doc = slurp(@url[3]);
        }
        when '' {
            $doc = slurp(@url[3]);
        }
    }
    if $doc {
        given @url[3].split('.')[*-1] {
            when 'txt' { return '<pre>' ~ $doc.subst('<', '&lt;').subst('&', '&amp;') ~ '</pre>'; }
            when 'html' | 'xhtml' { return $doc }
        } 
    }
    warn "did not inline $link";
    q:c{<a href="{$link}">{$content}</a>}
}

multi sub handle (Pod::FormattingCode $node where .type eq 'R', $context = None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    '<var class="replaceable">' ~ $node.contents>>.&handle($context) ~ '</var>'
}

multi sub handle (Pod::FormattingCode $node where .type eq 'Z', $context = None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    '<!-- ' ~ $node.contents>>.&handle($context) ~ ' -->'
}

multi sub handle (Pod::FormattingCode $node where .type eq 'V', $context = None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    '' ~ $node.contents>>.&handle($context) ~ ''
}

multi sub handle (Pod::FormattingCode $node where .type eq 'X', $context = None, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    my $additional-class = ($node.config && $node.config<class> ?? ' ' ~ $node.config<class> !! '').subst('"', '&quot;');
    my $index-display = $node.contents>>.&handle($context).Str;
    my @name = $node.meta>>.subst('&', '&amp;', :g).subst('"', '&quot;', :g).subst('<', '&lt;', :g).subst('>', '&gt;', :g);
    my $anchor = register-index-entry(@name, $node.contents, :$pod-name);
    Q:c (<span class="indexed{$additional-class}"><a id="{$anchor}" name="{@name}">{$index-display}</a></span>);
}

multi sub handle (Pod::FormattingCode $node where .type eq 'X', $context where * == Heading, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    my $index-display = $node.contents>>.&handle($context).Str;
    my $anchor = register-index-entry($node.meta, $node.contents, :$pod-name);
    q:c (<a name="{$anchor}"></a>{$index-display})
}

multi sub handle (Pod::Heading $node, :$pod-name?, :$part-number?, :$toc-counter, :%part-config) is export {
    %list-item-counter = ();
    my $class = $node.config && $node.config<class> ?? ' class = "' ~ $node.config<class>.subst('"', '&quot;') ~ '"' !! '';
    my $l = $node.level;
    my $text = $node.contents>>.&handle(Heading, :$pod-name).Str;
    my $raw-text = $node.contents>>.&handle(Raw).List.flat.join.trim;
    my $id = $pod-name.subst('.pod6', '') ~ '#' ~ $raw-text.subst(' ', '_', :g).subst('"','&quot;', :g);
    $id = rewrite-link($id, :$part-number).substr(1);
    if $node.config<numbered> || %part-config{'head' ~ $node.level}<numbered>.?Int {
        my $anchor = register-toc-entry($l, $text, $toc-counter);
        return Q:c (<a name="t{$anchor}"{$class}></a><h{$l} id="{$id}">{$anchor} {$text}</h{$l}>) ~ NL
    } else {
        my $anchor = register-toc-entry($l, $text, $toc-counter, :hide);    
        return Q:c (<a name="t{$anchor}"{$class}></a><h{$l} id="{$id}">{$text}</h{$l}>) ~ NL
    }
}

multi sub handle (Pod::Item $node, :$pod-name?, :$part-number?, :$toc-counter?, :%part-config?) is export {
    my $class = $node.config && $node.config<class> ?? ' class = "' ~ $node.config<class>.subst('"', '&quot;') ~ '"' !! '';
    "<ul><li$class>" x $node.level ~ $node.contents>>.&handle(:$pod-name, :$part-number) ~ '</li></ul>' x $node.level
}

multi sub handle (Pod::Item $node where so $node.config<:numbered>, :$part-number, :$toc-counter?, :%part-config?) is export {
    %list-item-counter = () if %list-item-counter{$node.level}:exists && %list-item-counter.keys.max > $node.level || $last-part-number != $part-number; 
    %list-item-counter{$node.level}++;
    $last-part-number = $part-number;
    my $class = $node.config && $node.config<class> ?? ' class = "' ~ $node.config<class>.subst('"', '&quot;') ~ '"' !! '';
    %list-item-counter.keys.sort.map({ "<ul class=\"numbered\"><li$class><span class=\"numbered-prefix\">{%list-item-counter{$_} ~ (%list-item-counter{$_+1}:exists ?? '.' !! '') }</span>"}) 
    ~ $node.contents>>.&handle()
    ~ "</li></ul>" x %list-item-counter.keys.elems + 1
    ~ NL;
}

multi sub handle (Pod::Raw $node, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    $node.contents>>.&handle()
}

# NYI
# multi sub handle (Pod::Block::Ambient $node) {
#   $node.perl.say;
#   $node.contents>>.&handle();
# }

multi sub handle (Str $node, Context $context?, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    $node.subst('&', '&amp;', :g).subst('<', '&lt;', :g);
}

multi sub handle (Str $node, Context $context where * == HTML, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    $node.Str;
}

multi sub handle (Nil, :$pod-name?, :$part-number?, :$toc-counter?) is export {
    die 'Nil';
}

