use v6;
use Typesafe::HTML;

multi sub xhtml-skeleton(*@children, :$header = [] -->HTML) is export {
    # for @children -> $e is rw {
    #     $e = HTML.new ~ $e unless $e ~~ HTML;
    # }
    @children.=map: { .item ~~ HTML ?? .item !! HTML.new ~ .item }
	HTML.new(q:c:to/END/);
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
{ $header>>.Str>>.indent(4).join("\n") || '    <title>untitled</title>' }
</head>

<body>
{ @children>>.Str>>.indent(4).join("\n") }
</body>
</html>
END
}

