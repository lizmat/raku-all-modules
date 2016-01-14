use v6;
use Test;
use XHTML::Writer :ALL;

plan 1;

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

