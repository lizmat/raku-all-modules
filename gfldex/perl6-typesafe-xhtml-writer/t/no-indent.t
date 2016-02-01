use v6;
use Test;
use Typesafe::XHTML::Writer :ALL;
writer-shall-indent True;

plan 1;

my $ok-result = Q:to/EOH/;
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

writer-shall-indent False;

is table(id=>'foo', class=>'de', tr(class=>'.tr', td(class=>'.td', 'abc'), td('ghj', br))) ~ "\n",
	$ok-result, 'no indentatoon';

