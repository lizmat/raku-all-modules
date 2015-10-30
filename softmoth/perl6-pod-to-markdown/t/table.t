use v6;
BEGIN { @*INC.unshift: 'blib/lib', 'lib' }

use Test;
use Pod::To::Markdown;
plan 1;

my $markdown = q{asdf

<table>
  <tr>
    <td>A A</td>
    <td>B B</td>
    <td>C C</td>
  </tr>
  <tr>
    <td>1 1</td>
    <td>2 2</td>
    <td>3 3</td>
  </tr>
</table>

asdf

<table>
  <thead>
    <tr>
      <td>H 1</td>
      <td>H 2</td>
      <td>H 3</td>
    </tr>
  </thead>
  <tr>
    <td>A A</td>
    <td>B B</td>
    <td>C C</td>
  </tr>
  <tr>
    <td>1 1</td>
    <td>2 2</td>
    <td>3 3</td>
  </tr>
</table>

asdf

<table>
  <thead>
    <tr>
      <td>H11</td>
      <td>HHH 222</td>
      <td>H 3</td>
    </tr>
  </thead>
  <tr>
    <td>AAA</td>
    <td>BB</td>
    <td>C C C C</td>
  </tr>
  <tr>
    <td>1 1</td>
    <td>2 2 2 2</td>
    <td>3 3</td>
  </tr>
</table>

asdf};

is pod2markdown($=pod).trim, $markdown.trim,
    'Converts tables correctly';

=begin pod
asdf
=begin table :caption('Table 1')
A A    B B       C C
1 1    2 2       3 3
=end table
asdf
=begin table :caption('Table 2')
H 1 | H 2 | H 3
====|=====|====
A A | B B | C C
1 1 | 2 2 | 3 3
=end table
asdf

=begin table :caption('Table 3')
       HHH
  H11  222  H 3
  ===  ===  ===
  AAA  BB   C C
            C C

  1 1  2 2  3 3
       2 2
=end table
asdf
=end pod
