use v6;
use Test;
use Typesafe::XHTML::Writer :p, :span, :title, :style;
use Typesafe::XHTML::Skeleton;

plan 6;


my $ok-result=q:to/END/;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
    <title>untitled</title>
</head>

<body>
    &lt;p>Hello Camelia!&lt;/p>
</body>
</html>
END

is xhtml-skeleton('<p>Hello Camelia!</p>'), $ok-result, 'quoting of Str';

$ok-result=q:to/END/;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
    <title>untitled</title>
</head>

<body>
    <p>
      Hello Camelia!
    </p>
</body>
</html>
END

try {xhtml-skeleton('<p>Hello Camelia!</p>'); CATCH { default { .^name.note } } }
is xhtml-skeleton(p('Hello Camelia!')), $ok-result, 'basic skeleton';

$ok-result=q:to/END/;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
    <title>untitled</title>
</head>

<body>
    &lt;p>Hello Camelia!&lt;/p>
</body>
</html>
END

is xhtml-skeleton('<p>Hello Camelia!</p>'), $ok-result, 'autoquoting of !~~HTML';

$ok-result=q:to/END/;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
    <title>untitled</title>
</head>

<body>
    <span>
      Hello Camelia!
    </span>
    quote all the &lt;&lt;&lt;&lt; and &amp;&amp;&amp;&amp;
</body>
</html>
END

is xhtml-skeleton(span('Hello Camelia!'), 'quote all the <<<< and &&&&'), $ok-result, 'mixed content';

$ok-result=q:to/END/;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
    <title>
      single header element
    </title>
</head>

<body>

</body>
</html>
END

is xhtml-skeleton('', header=>title('single header element')), $ok-result, 'single header element';


$ok-result=q:to/END/;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
    <title>
      multi header element
    </title>
    <style>
      &lt;&amp;
    </style>
</head>

<body>

</body>
</html>
END

is xhtml-skeleton('', header=>(title('multi header element'), style('<&'))), $ok-result, 'multi header element';

