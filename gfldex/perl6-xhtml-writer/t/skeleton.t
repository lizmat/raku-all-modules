use v6;
use Test;
use XHTML::Writer :p;
use XHTML::Skeleton;

plan 2;

my $ok-result=q:to/END/;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8"/>
    <title>skeleton.t</title>
</head>

<body>
    <p>
      Hello World!
    </p>
</body>
</html>
END

is xhtml-skeleton(p('Hello World!'), header=>'<title>skeleton.t</title>'),
	$ok-result, 'skeleton with header';

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
      Hello Workd!
    </p>
</body>
</html>
END

is xhtml-skeleton(p('Hello Workd!')), $ok-result, 'basic skeleton';

