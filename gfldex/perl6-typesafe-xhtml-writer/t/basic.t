use v6;
use Test;
use Typesafe::XHTML::Writer :ALL;

plan 2;

my $basic-example = Q:to/EOH/;
<table id="foo" class="de">
  <tr class=".tr">
    <td class=".td">
      abc
    </td>
    <td>
      ghj
      <br/>
    </td>
  </tr>
</table>
EOH

is table(id=>'foo', class=>'de', tr(class=>'.tr', td(class=>'.td', 'abc'), td('ghj', br))) ~ "\n",
	$basic-example, 'basic table';

my $autoquoting = Q:to/EOH/;
<span>
  &lt;p>Hello Camelia!&lt;/p>
</span>
EOH

is span('<p>Hello Camelia!</p>').Str ~ "\n", $autoquoting, 'autoquoting of !~~ HTML';

