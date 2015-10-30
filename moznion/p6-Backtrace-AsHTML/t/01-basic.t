use v6;
use Test;
use Backtrace::AsHTML;

my $html;

my sub foo(Str $arg) {
    my $t = Backtrace.new;
    $html = $t.as-html;
}

my sub bar(Int $arg) {
    foo("bar")
}
bar(2);

like $html, rx{'in block &lt;unit&gt; at t/01-basic.t:15'};
like $html, rx{'in bar at t/01-basic.t line 15'};
like $html, rx{'in foo at t/01-basic.t line 12'};
like $html, rx{'in new at t/01-basic.t line 8'};

done-testing;

