use v6;

sub xhtml-skeleton(*@children, :@header) is export {
	q:c:to/END/;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
{ @header>>.indent(4).join("\n") || '    <title>untitled</title>' }
</head>

<body>
{ @children>>.indent(4).join("\n") }
</body>
</html>
END
}
