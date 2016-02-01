use v6;
use Typesafe::HTML;
my $indent = 0;

constant NL = "\n";
my $Guard = HTML;
my Bool $shall-indent = False;
sub html ( :$lang?, :$xml-lang?, :$dir?, :$id?, *@c --> HTML) is export(:ALL :html) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<html' ~ 
           ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</html>') 
              !! '/>' )
    )
}


sub head ( :$lang?, :$xml-lang?, :$dir?, :$id?, :$profile?, *@c --> HTML) is export(:ALL :head) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<head' ~ 
           ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($profile ?? ' profile' ~ '=' ~ "\"$profile\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</head>') 
              !! '/>' )
    )
}


sub title ( :$lang?, :$xml-lang?, :$dir?, :$id?, *@c --> HTML) is export(:ALL :title) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<title' ~ 
           ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</title>') 
              !! '/>' )
    )
}


sub base ( :$href?, :$id?, *@c --> HTML) is export(:ALL :base) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<base' ~ 
           ($href ?? ' href' ~ '=' ~ "\"$href\"" !! Empty) ~
    ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</base>') 
              !! '/>' )
    )
}


sub meta ( :$lang?, :$xml-lang?, :$dir?, :$id?, :$http-equiv?, :$name?, :$content?, :$scheme?, *@c --> HTML) is export(:ALL :meta) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<meta' ~ 
           ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($http-equiv ?? ' http-equiv' ~ '=' ~ "\"$http-equiv\"" !! Empty) ~
    ($name ?? ' name' ~ '=' ~ "\"$name\"" !! Empty) ~
    ($content ?? ' content' ~ '=' ~ "\"$content\"" !! Empty) ~
    ($scheme ?? ' scheme' ~ '=' ~ "\"$scheme\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</meta>') 
              !! '/>' )
    )
}


sub link ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$charset?, :$href?, :$hreflang?, :$type?, :$rel?, :$rev?, :$media?, *@c --> HTML) is export(:ALL :link) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<link' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($charset ?? ' charset' ~ '=' ~ "\"$charset\"" !! Empty) ~
    ($href ?? ' href' ~ '=' ~ "\"$href\"" !! Empty) ~
    ($hreflang ?? ' hreflang' ~ '=' ~ "\"$hreflang\"" !! Empty) ~
    ($type ?? ' type' ~ '=' ~ "\"$type\"" !! Empty) ~
    ($rel ?? ' rel' ~ '=' ~ "\"$rel\"" !! Empty) ~
    ($rev ?? ' rev' ~ '=' ~ "\"$rev\"" !! Empty) ~
    ($media ?? ' media' ~ '=' ~ "\"$media\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</link>') 
              !! '/>' )
    )
}


sub style ( :$lang?, :$xml-lang?, :$dir?, :$id?, :$type?, :$media?, :$title?, :$xml-space?, *@c --> HTML) is export(:ALL :style) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<style' ~ 
           ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($type ?? ' type' ~ '=' ~ "\"$type\"" !! Empty) ~
    ($media ?? ' media' ~ '=' ~ "\"$media\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($xml-space ?? ' xml:space' ~ '=' ~ "\"$xml-space\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</style>') 
              !! '/>' )
    )
}


sub script ( :$id?, :$charset?, :$type?, :$src?, :$defer?, :$xml-space?, *@c --> HTML) is export(:ALL :script) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<script' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($charset ?? ' charset' ~ '=' ~ "\"$charset\"" !! Empty) ~
    ($type ?? ' type' ~ '=' ~ "\"$type\"" !! Empty) ~
    ($src ?? ' src' ~ '=' ~ "\"$src\"" !! Empty) ~
    ($defer ?? ' defer' ~ '=' ~ "\"$defer\"" !! Empty) ~
    ($xml-space ?? ' xml:space' ~ '=' ~ "\"$xml-space\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</script>') 
              !! '/>' )
    )
}


sub noscript ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :noscript) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<noscript' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</noscript>') 
              !! '/>' )
    )
}


sub body ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$onload?, :$onunload?, *@c --> HTML) is export(:ALL :body) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<body' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($onload ?? ' onload' ~ '=' ~ "\"$onload\"" !! Empty) ~
    ($onunload ?? ' onunload' ~ '=' ~ "\"$onunload\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</body>') 
              !! '/>' )
    )
}


sub div ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :div) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<div' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</div>') 
              !! '/>' )
    )
}


sub p ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :p) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<p' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</p>') 
              !! '/>' )
    )
}


sub h1 ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :h1) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<h1' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</h1>') 
              !! '/>' )
    )
}


sub h2 ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :h2) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<h2' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</h2>') 
              !! '/>' )
    )
}


sub h3 ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :h3) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<h3' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</h3>') 
              !! '/>' )
    )
}


sub h4 ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :h4) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<h4' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</h4>') 
              !! '/>' )
    )
}


sub h5 ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :h5) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<h5' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</h5>') 
              !! '/>' )
    )
}


sub h6 ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :h6) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<h6' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</h6>') 
              !! '/>' )
    )
}


sub ul ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :ul) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<ul' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</ul>') 
              !! '/>' )
    )
}


sub ol ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :ol) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<ol' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</ol>') 
              !! '/>' )
    )
}


sub li ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :li) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<li' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</li>') 
              !! '/>' )
    )
}


sub dl ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :dl) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<dl' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</dl>') 
              !! '/>' )
    )
}


sub dt ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :dt) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<dt' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</dt>') 
              !! '/>' )
    )
}


sub dd ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :dd) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<dd' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</dd>') 
              !! '/>' )
    )
}


sub address ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :address) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<address' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</address>') 
              !! '/>' )
    )
}


sub hr ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :hr) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<hr' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</hr>') 
              !! '/>' )
    )
}


sub pre ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$xml-space?, *@c --> HTML) is export(:ALL :pre) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<pre' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($xml-space ?? ' xml:space' ~ '=' ~ "\"$xml-space\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</pre>') 
              !! '/>' )
    )
}


sub blockquote ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$cite?, *@c --> HTML) is export(:ALL :blockquote) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<blockquote' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($cite ?? ' cite' ~ '=' ~ "\"$cite\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</blockquote>') 
              !! '/>' )
    )
}


sub ins ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$cite?, :$datetime?, *@c --> HTML) is export(:ALL :ins) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<ins' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($cite ?? ' cite' ~ '=' ~ "\"$cite\"" !! Empty) ~
    ($datetime ?? ' datetime' ~ '=' ~ "\"$datetime\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</ins>') 
              !! '/>' )
    )
}


sub del ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$cite?, :$datetime?, *@c --> HTML) is export(:ALL :del) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<del' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($cite ?? ' cite' ~ '=' ~ "\"$cite\"" !! Empty) ~
    ($datetime ?? ' datetime' ~ '=' ~ "\"$datetime\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</del>') 
              !! '/>' )
    )
}


sub a ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$accesskey?, :$tabindex?, :$onfocus?, :$onblur?, :$charset?, :$type?, :$name?, :$href?, :$hreflang?, :$rel?, :$rev?, :$shape?, :$coords?, *@c --> HTML) is export(:ALL :a) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<a' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($accesskey ?? ' accesskey' ~ '=' ~ "\"$accesskey\"" !! Empty) ~
    ($tabindex ?? ' tabindex' ~ '=' ~ "\"$tabindex\"" !! Empty) ~
    ($onfocus ?? ' onfocus' ~ '=' ~ "\"$onfocus\"" !! Empty) ~
    ($onblur ?? ' onblur' ~ '=' ~ "\"$onblur\"" !! Empty) ~
    ($charset ?? ' charset' ~ '=' ~ "\"$charset\"" !! Empty) ~
    ($type ?? ' type' ~ '=' ~ "\"$type\"" !! Empty) ~
    ($name ?? ' name' ~ '=' ~ "\"$name\"" !! Empty) ~
    ($href ?? ' href' ~ '=' ~ "\"$href\"" !! Empty) ~
    ($hreflang ?? ' hreflang' ~ '=' ~ "\"$hreflang\"" !! Empty) ~
    ($rel ?? ' rel' ~ '=' ~ "\"$rel\"" !! Empty) ~
    ($rev ?? ' rev' ~ '=' ~ "\"$rev\"" !! Empty) ~
    ($shape ?? ' shape' ~ '=' ~ "\"$shape\"" !! Empty) ~
    ($coords ?? ' coords' ~ '=' ~ "\"$coords\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</a>') 
              !! '/>' )
    )
}


sub span ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :span) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<span' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</span>') 
              !! '/>' )
    )
}


sub bdo ( :$id?, :$class?, :$style?, :$title?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$lang?, :$xml-lang?, :$dir?, *@c --> HTML) is export(:ALL :bdo) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<bdo' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</bdo>') 
              !! '/>' )
    )
}


sub br ( :$id?, :$class?, :$style?, :$title?, *@c --> HTML) is export(:ALL :br) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<br' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</br>') 
              !! '/>' )
    )
}


sub em ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :em) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<em' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</em>') 
              !! '/>' )
    )
}


sub strong ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :strong) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<strong' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</strong>') 
              !! '/>' )
    )
}


sub dfn ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :dfn) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<dfn' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</dfn>') 
              !! '/>' )
    )
}


sub code ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :code) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<code' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</code>') 
              !! '/>' )
    )
}


sub samp ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :samp) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<samp' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</samp>') 
              !! '/>' )
    )
}


sub kbd ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :kbd) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<kbd' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</kbd>') 
              !! '/>' )
    )
}


sub var ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :var) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<var' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</var>') 
              !! '/>' )
    )
}


sub cite ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :cite) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<cite' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</cite>') 
              !! '/>' )
    )
}


sub abbr ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :abbr) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<abbr' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</abbr>') 
              !! '/>' )
    )
}


sub acronym ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :acronym) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<acronym' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</acronym>') 
              !! '/>' )
    )
}


sub q ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$cite?, *@c --> HTML) is export(:ALL :q) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<q' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($cite ?? ' cite' ~ '=' ~ "\"$cite\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</q>') 
              !! '/>' )
    )
}


sub sub ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :sub) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<sub' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</sub>') 
              !! '/>' )
    )
}


sub sup ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :sup) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<sup' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</sup>') 
              !! '/>' )
    )
}


sub tt ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :tt) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<tt' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</tt>') 
              !! '/>' )
    )
}


sub i ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :i) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<i' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</i>') 
              !! '/>' )
    )
}


sub b ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :b) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<b' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</b>') 
              !! '/>' )
    )
}


sub big ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :big) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<big' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</big>') 
              !! '/>' )
    )
}


sub small ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :small) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<small' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</small>') 
              !! '/>' )
    )
}


sub object ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$declare?, :$classid?, :$codebase?, :$data?, :$type?, :$codetype?, :$archive?, :$standby?, :$height?, :$width?, :$usemap?, :$name?, :$tabindex?, *@c --> HTML) is export(:ALL :object) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<object' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($declare ?? ' declare' ~ '=' ~ "\"$declare\"" !! Empty) ~
    ($classid ?? ' classid' ~ '=' ~ "\"$classid\"" !! Empty) ~
    ($codebase ?? ' codebase' ~ '=' ~ "\"$codebase\"" !! Empty) ~
    ($data ?? ' data' ~ '=' ~ "\"$data\"" !! Empty) ~
    ($type ?? ' type' ~ '=' ~ "\"$type\"" !! Empty) ~
    ($codetype ?? ' codetype' ~ '=' ~ "\"$codetype\"" !! Empty) ~
    ($archive ?? ' archive' ~ '=' ~ "\"$archive\"" !! Empty) ~
    ($standby ?? ' standby' ~ '=' ~ "\"$standby\"" !! Empty) ~
    ($height ?? ' height' ~ '=' ~ "\"$height\"" !! Empty) ~
    ($width ?? ' width' ~ '=' ~ "\"$width\"" !! Empty) ~
    ($usemap ?? ' usemap' ~ '=' ~ "\"$usemap\"" !! Empty) ~
    ($name ?? ' name' ~ '=' ~ "\"$name\"" !! Empty) ~
    ($tabindex ?? ' tabindex' ~ '=' ~ "\"$tabindex\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</object>') 
              !! '/>' )
    )
}


sub param ( :$id?, :$name?, :$value?, :$valuetype?, :$type?, *@c --> HTML) is export(:ALL :param) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<param' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($name ?? ' name' ~ '=' ~ "\"$name\"" !! Empty) ~
    ($value ?? ' value' ~ '=' ~ "\"$value\"" !! Empty) ~
    ($valuetype ?? ' valuetype' ~ '=' ~ "\"$valuetype\"" !! Empty) ~
    ($type ?? ' type' ~ '=' ~ "\"$type\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</param>') 
              !! '/>' )
    )
}


sub img ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$src?, :$alt?, :$longdesc?, :$height?, :$width?, :$usemap?, :$ismap?, *@c --> HTML) is export(:ALL :img) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<img' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($src ?? ' src' ~ '=' ~ "\"$src\"" !! Empty) ~
    ($alt ?? ' alt' ~ '=' ~ "\"$alt\"" !! Empty) ~
    ($longdesc ?? ' longdesc' ~ '=' ~ "\"$longdesc\"" !! Empty) ~
    ($height ?? ' height' ~ '=' ~ "\"$height\"" !! Empty) ~
    ($width ?? ' width' ~ '=' ~ "\"$width\"" !! Empty) ~
    ($usemap ?? ' usemap' ~ '=' ~ "\"$usemap\"" !! Empty) ~
    ($ismap ?? ' ismap' ~ '=' ~ "\"$ismap\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</img>') 
              !! '/>' )
    )
}


sub map ( :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$id?, :$class?, :$style?, :$title?, :$name?, *@c --> HTML) is export(:ALL :map) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<map' ~ 
           ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($name ?? ' name' ~ '=' ~ "\"$name\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</map>') 
              !! '/>' )
    )
}


sub area ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$accesskey?, :$tabindex?, :$onfocus?, :$onblur?, :$shape?, :$coords?, :$href?, :$nohref?, :$alt?, *@c --> HTML) is export(:ALL :area) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<area' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($accesskey ?? ' accesskey' ~ '=' ~ "\"$accesskey\"" !! Empty) ~
    ($tabindex ?? ' tabindex' ~ '=' ~ "\"$tabindex\"" !! Empty) ~
    ($onfocus ?? ' onfocus' ~ '=' ~ "\"$onfocus\"" !! Empty) ~
    ($onblur ?? ' onblur' ~ '=' ~ "\"$onblur\"" !! Empty) ~
    ($shape ?? ' shape' ~ '=' ~ "\"$shape\"" !! Empty) ~
    ($coords ?? ' coords' ~ '=' ~ "\"$coords\"" !! Empty) ~
    ($href ?? ' href' ~ '=' ~ "\"$href\"" !! Empty) ~
    ($nohref ?? ' nohref' ~ '=' ~ "\"$nohref\"" !! Empty) ~
    ($alt ?? ' alt' ~ '=' ~ "\"$alt\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</area>') 
              !! '/>' )
    )
}


sub form ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$action?, :$method?, :$enctype?, :$onsubmit?, :$onreset?, :$accept?, :$accept-charset?, *@c --> HTML) is export(:ALL :form) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<form' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($action ?? ' action' ~ '=' ~ "\"$action\"" !! Empty) ~
    ($method ?? ' method' ~ '=' ~ "\"$method\"" !! Empty) ~
    ($enctype ?? ' enctype' ~ '=' ~ "\"$enctype\"" !! Empty) ~
    ($onsubmit ?? ' onsubmit' ~ '=' ~ "\"$onsubmit\"" !! Empty) ~
    ($onreset ?? ' onreset' ~ '=' ~ "\"$onreset\"" !! Empty) ~
    ($accept ?? ' accept' ~ '=' ~ "\"$accept\"" !! Empty) ~
    ($accept-charset ?? ' accept-charset' ~ '=' ~ "\"$accept-charset\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</form>') 
              !! '/>' )
    )
}


sub label ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$for?, :$accesskey?, :$onfocus?, :$onblur?, *@c --> HTML) is export(:ALL :label) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<label' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($for ?? ' for' ~ '=' ~ "\"$for\"" !! Empty) ~
    ($accesskey ?? ' accesskey' ~ '=' ~ "\"$accesskey\"" !! Empty) ~
    ($onfocus ?? ' onfocus' ~ '=' ~ "\"$onfocus\"" !! Empty) ~
    ($onblur ?? ' onblur' ~ '=' ~ "\"$onblur\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</label>') 
              !! '/>' )
    )
}


sub input ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$accesskey?, :$tabindex?, :$onfocus?, :$onblur?, :$type?, :$name?, :$value?, :$checked?, :$disabled?, :$readonly?, :$size?, :$maxlength?, :$src?, :$alt?, :$usemap?, :$onselect?, :$onchange?, :$accept?, *@c --> HTML) is export(:ALL :input) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<input' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($accesskey ?? ' accesskey' ~ '=' ~ "\"$accesskey\"" !! Empty) ~
    ($tabindex ?? ' tabindex' ~ '=' ~ "\"$tabindex\"" !! Empty) ~
    ($onfocus ?? ' onfocus' ~ '=' ~ "\"$onfocus\"" !! Empty) ~
    ($onblur ?? ' onblur' ~ '=' ~ "\"$onblur\"" !! Empty) ~
    ($type ?? ' type' ~ '=' ~ "\"$type\"" !! Empty) ~
    ($name ?? ' name' ~ '=' ~ "\"$name\"" !! Empty) ~
    ($value ?? ' value' ~ '=' ~ "\"$value\"" !! Empty) ~
    ($checked ?? ' checked' ~ '=' ~ "\"$checked\"" !! Empty) ~
    ($disabled ?? ' disabled' ~ '=' ~ "\"$disabled\"" !! Empty) ~
    ($readonly ?? ' readonly' ~ '=' ~ "\"$readonly\"" !! Empty) ~
    ($size ?? ' size' ~ '=' ~ "\"$size\"" !! Empty) ~
    ($maxlength ?? ' maxlength' ~ '=' ~ "\"$maxlength\"" !! Empty) ~
    ($src ?? ' src' ~ '=' ~ "\"$src\"" !! Empty) ~
    ($alt ?? ' alt' ~ '=' ~ "\"$alt\"" !! Empty) ~
    ($usemap ?? ' usemap' ~ '=' ~ "\"$usemap\"" !! Empty) ~
    ($onselect ?? ' onselect' ~ '=' ~ "\"$onselect\"" !! Empty) ~
    ($onchange ?? ' onchange' ~ '=' ~ "\"$onchange\"" !! Empty) ~
    ($accept ?? ' accept' ~ '=' ~ "\"$accept\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</input>') 
              !! '/>' )
    )
}


sub select ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$name?, :$size?, :$multiple?, :$disabled?, :$tabindex?, :$onfocus?, :$onblur?, :$onchange?, *@c --> HTML) is export(:ALL :select) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<select' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($name ?? ' name' ~ '=' ~ "\"$name\"" !! Empty) ~
    ($size ?? ' size' ~ '=' ~ "\"$size\"" !! Empty) ~
    ($multiple ?? ' multiple' ~ '=' ~ "\"$multiple\"" !! Empty) ~
    ($disabled ?? ' disabled' ~ '=' ~ "\"$disabled\"" !! Empty) ~
    ($tabindex ?? ' tabindex' ~ '=' ~ "\"$tabindex\"" !! Empty) ~
    ($onfocus ?? ' onfocus' ~ '=' ~ "\"$onfocus\"" !! Empty) ~
    ($onblur ?? ' onblur' ~ '=' ~ "\"$onblur\"" !! Empty) ~
    ($onchange ?? ' onchange' ~ '=' ~ "\"$onchange\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</select>') 
              !! '/>' )
    )
}


sub optgroup ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$disabled?, :$label?, *@c --> HTML) is export(:ALL :optgroup) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<optgroup' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($disabled ?? ' disabled' ~ '=' ~ "\"$disabled\"" !! Empty) ~
    ($label ?? ' label' ~ '=' ~ "\"$label\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</optgroup>') 
              !! '/>' )
    )
}


sub option ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$selected?, :$disabled?, :$label?, :$value?, *@c --> HTML) is export(:ALL :option) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<option' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($selected ?? ' selected' ~ '=' ~ "\"$selected\"" !! Empty) ~
    ($disabled ?? ' disabled' ~ '=' ~ "\"$disabled\"" !! Empty) ~
    ($label ?? ' label' ~ '=' ~ "\"$label\"" !! Empty) ~
    ($value ?? ' value' ~ '=' ~ "\"$value\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</option>') 
              !! '/>' )
    )
}


sub textarea ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$accesskey?, :$tabindex?, :$onfocus?, :$onblur?, :$name?, :$rows?, :$cols?, :$disabled?, :$readonly?, :$onselect?, :$onchange?, *@c --> HTML) is export(:ALL :textarea) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<textarea' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($accesskey ?? ' accesskey' ~ '=' ~ "\"$accesskey\"" !! Empty) ~
    ($tabindex ?? ' tabindex' ~ '=' ~ "\"$tabindex\"" !! Empty) ~
    ($onfocus ?? ' onfocus' ~ '=' ~ "\"$onfocus\"" !! Empty) ~
    ($onblur ?? ' onblur' ~ '=' ~ "\"$onblur\"" !! Empty) ~
    ($name ?? ' name' ~ '=' ~ "\"$name\"" !! Empty) ~
    ($rows ?? ' rows' ~ '=' ~ "\"$rows\"" !! Empty) ~
    ($cols ?? ' cols' ~ '=' ~ "\"$cols\"" !! Empty) ~
    ($disabled ?? ' disabled' ~ '=' ~ "\"$disabled\"" !! Empty) ~
    ($readonly ?? ' readonly' ~ '=' ~ "\"$readonly\"" !! Empty) ~
    ($onselect ?? ' onselect' ~ '=' ~ "\"$onselect\"" !! Empty) ~
    ($onchange ?? ' onchange' ~ '=' ~ "\"$onchange\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</textarea>') 
              !! '/>' )
    )
}


sub fieldset ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :fieldset) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<fieldset' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</fieldset>') 
              !! '/>' )
    )
}


sub legend ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$accesskey?, *@c --> HTML) is export(:ALL :legend) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<legend' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($accesskey ?? ' accesskey' ~ '=' ~ "\"$accesskey\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</legend>') 
              !! '/>' )
    )
}


sub button ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$accesskey?, :$tabindex?, :$onfocus?, :$onblur?, :$name?, :$value?, :$type?, :$disabled?, *@c --> HTML) is export(:ALL :button) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<button' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($accesskey ?? ' accesskey' ~ '=' ~ "\"$accesskey\"" !! Empty) ~
    ($tabindex ?? ' tabindex' ~ '=' ~ "\"$tabindex\"" !! Empty) ~
    ($onfocus ?? ' onfocus' ~ '=' ~ "\"$onfocus\"" !! Empty) ~
    ($onblur ?? ' onblur' ~ '=' ~ "\"$onblur\"" !! Empty) ~
    ($name ?? ' name' ~ '=' ~ "\"$name\"" !! Empty) ~
    ($value ?? ' value' ~ '=' ~ "\"$value\"" !! Empty) ~
    ($type ?? ' type' ~ '=' ~ "\"$type\"" !! Empty) ~
    ($disabled ?? ' disabled' ~ '=' ~ "\"$disabled\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</button>') 
              !! '/>' )
    )
}


sub table ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$summary?, :$width?, :$border?, :$frame?, :$rules?, :$cellspacing?, :$cellpadding?, *@c --> HTML) is export(:ALL :table) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<table' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($summary ?? ' summary' ~ '=' ~ "\"$summary\"" !! Empty) ~
    ($width ?? ' width' ~ '=' ~ "\"$width\"" !! Empty) ~
    ($border ?? ' border' ~ '=' ~ "\"$border\"" !! Empty) ~
    ($frame ?? ' frame' ~ '=' ~ "\"$frame\"" !! Empty) ~
    ($rules ?? ' rules' ~ '=' ~ "\"$rules\"" !! Empty) ~
    ($cellspacing ?? ' cellspacing' ~ '=' ~ "\"$cellspacing\"" !! Empty) ~
    ($cellpadding ?? ' cellpadding' ~ '=' ~ "\"$cellpadding\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</table>') 
              !! '/>' )
    )
}


sub caption ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, *@c --> HTML) is export(:ALL :caption) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<caption' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</caption>') 
              !! '/>' )
    )
}


sub thead ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$align?, :$char?, :$charoff?, :$valign?, *@c --> HTML) is export(:ALL :thead) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<thead' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($align ?? ' align' ~ '=' ~ "\"$align\"" !! Empty) ~
    ($char ?? ' char' ~ '=' ~ "\"$char\"" !! Empty) ~
    ($charoff ?? ' charoff' ~ '=' ~ "\"$charoff\"" !! Empty) ~
    ($valign ?? ' valign' ~ '=' ~ "\"$valign\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</thead>') 
              !! '/>' )
    )
}


sub tfoot ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$align?, :$char?, :$charoff?, :$valign?, *@c --> HTML) is export(:ALL :tfoot) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<tfoot' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($align ?? ' align' ~ '=' ~ "\"$align\"" !! Empty) ~
    ($char ?? ' char' ~ '=' ~ "\"$char\"" !! Empty) ~
    ($charoff ?? ' charoff' ~ '=' ~ "\"$charoff\"" !! Empty) ~
    ($valign ?? ' valign' ~ '=' ~ "\"$valign\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</tfoot>') 
              !! '/>' )
    )
}


sub tbody ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$align?, :$char?, :$charoff?, :$valign?, *@c --> HTML) is export(:ALL :tbody) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<tbody' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($align ?? ' align' ~ '=' ~ "\"$align\"" !! Empty) ~
    ($char ?? ' char' ~ '=' ~ "\"$char\"" !! Empty) ~
    ($charoff ?? ' charoff' ~ '=' ~ "\"$charoff\"" !! Empty) ~
    ($valign ?? ' valign' ~ '=' ~ "\"$valign\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</tbody>') 
              !! '/>' )
    )
}


sub colgroup ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$span?, :$width?, :$align?, :$char?, :$charoff?, :$valign?, *@c --> HTML) is export(:ALL :colgroup) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<colgroup' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($span ?? ' span' ~ '=' ~ "\"$span\"" !! Empty) ~
    ($width ?? ' width' ~ '=' ~ "\"$width\"" !! Empty) ~
    ($align ?? ' align' ~ '=' ~ "\"$align\"" !! Empty) ~
    ($char ?? ' char' ~ '=' ~ "\"$char\"" !! Empty) ~
    ($charoff ?? ' charoff' ~ '=' ~ "\"$charoff\"" !! Empty) ~
    ($valign ?? ' valign' ~ '=' ~ "\"$valign\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</colgroup>') 
              !! '/>' )
    )
}


sub col ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$span?, :$width?, :$align?, :$char?, :$charoff?, :$valign?, *@c --> HTML) is export(:ALL :col) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<col' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($span ?? ' span' ~ '=' ~ "\"$span\"" !! Empty) ~
    ($width ?? ' width' ~ '=' ~ "\"$width\"" !! Empty) ~
    ($align ?? ' align' ~ '=' ~ "\"$align\"" !! Empty) ~
    ($char ?? ' char' ~ '=' ~ "\"$char\"" !! Empty) ~
    ($charoff ?? ' charoff' ~ '=' ~ "\"$charoff\"" !! Empty) ~
    ($valign ?? ' valign' ~ '=' ~ "\"$valign\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</col>') 
              !! '/>' )
    )
}


sub tr ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$align?, :$char?, :$charoff?, :$valign?, *@c --> HTML) is export(:ALL :tr) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<tr' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($align ?? ' align' ~ '=' ~ "\"$align\"" !! Empty) ~
    ($char ?? ' char' ~ '=' ~ "\"$char\"" !! Empty) ~
    ($charoff ?? ' charoff' ~ '=' ~ "\"$charoff\"" !! Empty) ~
    ($valign ?? ' valign' ~ '=' ~ "\"$valign\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</tr>') 
              !! '/>' )
    )
}


sub th ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$abbr?, :$axis?, :$headers?, :$scope?, :$rowspan?, :$colspan?, :$align?, :$char?, :$charoff?, :$valign?, *@c --> HTML) is export(:ALL :th) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<th' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($abbr ?? ' abbr' ~ '=' ~ "\"$abbr\"" !! Empty) ~
    ($axis ?? ' axis' ~ '=' ~ "\"$axis\"" !! Empty) ~
    ($headers ?? ' headers' ~ '=' ~ "\"$headers\"" !! Empty) ~
    ($scope ?? ' scope' ~ '=' ~ "\"$scope\"" !! Empty) ~
    ($rowspan ?? ' rowspan' ~ '=' ~ "\"$rowspan\"" !! Empty) ~
    ($colspan ?? ' colspan' ~ '=' ~ "\"$colspan\"" !! Empty) ~
    ($align ?? ' align' ~ '=' ~ "\"$align\"" !! Empty) ~
    ($char ?? ' char' ~ '=' ~ "\"$char\"" !! Empty) ~
    ($charoff ?? ' charoff' ~ '=' ~ "\"$charoff\"" !! Empty) ~
    ($valign ?? ' valign' ~ '=' ~ "\"$valign\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</th>') 
              !! '/>' )
    )
}


sub td ( :$id?, :$class?, :$style?, :$title?, :$lang?, :$xml-lang?, :$dir?, :$onclick?, :$ondblclick?, :$onmousedown?, :$onmouseup?, :$onmouseover?, :$onmousemove?, :$onmouseout?, :$onkeypress?, :$onkeydown?, :$onkeyup?, :$abbr?, :$axis?, :$headers?, :$scope?, :$rowspan?, :$colspan?, :$align?, :$char?, :$charoff?, :$valign?, *@c --> HTML) is export(:ALL :td) {
    (temp $indent)+=2;
		my $indentor;
		my method indent(){ my $index = 0; $index += 2 while self.subst-eq('  ', $index); $indentor = '  ' x $index+2; }
    for @c -> $e is rw { $e = $Guard.new ~ $e.Str unless $e ~~ HTML }
    $Guard.new(
        '<td' ~ 
           ($id ?? ' id' ~ '=' ~ "\"$id\"" !! Empty) ~
    ($class ?? ' class' ~ '=' ~ "\"$class\"" !! Empty) ~
    ($style ?? ' style' ~ '=' ~ "\"$style\"" !! Empty) ~
    ($title ?? ' title' ~ '=' ~ "\"$title\"" !! Empty) ~
    ($lang ?? ' lang' ~ '=' ~ "\"$lang\"" !! Empty) ~
    ($xml-lang ?? ' xml:lang' ~ '=' ~ "\"$xml-lang\"" !! Empty) ~
    ($dir ?? ' dir' ~ '=' ~ "\"$dir\"" !! Empty) ~
    ($onclick ?? ' onclick' ~ '=' ~ "\"$onclick\"" !! Empty) ~
    ($ondblclick ?? ' ondblclick' ~ '=' ~ "\"$ondblclick\"" !! Empty) ~
    ($onmousedown ?? ' onmousedown' ~ '=' ~ "\"$onmousedown\"" !! Empty) ~
    ($onmouseup ?? ' onmouseup' ~ '=' ~ "\"$onmouseup\"" !! Empty) ~
    ($onmouseover ?? ' onmouseover' ~ '=' ~ "\"$onmouseover\"" !! Empty) ~
    ($onmousemove ?? ' onmousemove' ~ '=' ~ "\"$onmousemove\"" !! Empty) ~
    ($onmouseout ?? ' onmouseout' ~ '=' ~ "\"$onmouseout\"" !! Empty) ~
    ($onkeypress ?? ' onkeypress' ~ '=' ~ "\"$onkeypress\"" !! Empty) ~
    ($onkeydown ?? ' onkeydown' ~ '=' ~ "\"$onkeydown\"" !! Empty) ~
    ($onkeyup ?? ' onkeyup' ~ '=' ~ "\"$onkeyup\"" !! Empty) ~
    ($abbr ?? ' abbr' ~ '=' ~ "\"$abbr\"" !! Empty) ~
    ($axis ?? ' axis' ~ '=' ~ "\"$axis\"" !! Empty) ~
    ($headers ?? ' headers' ~ '=' ~ "\"$headers\"" !! Empty) ~
    ($scope ?? ' scope' ~ '=' ~ "\"$scope\"" !! Empty) ~
    ($rowspan ?? ' rowspan' ~ '=' ~ "\"$rowspan\"" !! Empty) ~
    ($colspan ?? ' colspan' ~ '=' ~ "\"$colspan\"" !! Empty) ~
    ($align ?? ' align' ~ '=' ~ "\"$align\"" !! Empty) ~
    ($char ?? ' char' ~ '=' ~ "\"$char\"" !! Empty) ~
    ($charoff ?? ' charoff' ~ '=' ~ "\"$charoff\"" !! Empty) ~
    ($valign ?? ' valign' ~ '=' ~ "\"$valign\"" !! Empty) ~
 
        ( +@c ?? ('>' ~ NL ~ ($shall-indent ?? @c>>.Str>>.indent($indent).join(NL) !! @c>>.Str.join(NL) )~ (+@c ?? NL !! "") ~ '</td>') 
              !! '/>' )
    )
}


sub writer-shall-indent(Bool $shall-it) is export(:ALL :writer-shall-indent) { $shall-indent = $shall-it }
sub EXPORT(::Guard = HTML) {
	$Guard = Guard;
	{
		Guard => $Guard,
    }
}

