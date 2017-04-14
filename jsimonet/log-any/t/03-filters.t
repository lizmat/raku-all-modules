use v6.c;

=begin pod
=head1 Test if Log::Any logs correctly.

=item1 Test on msg filter with Str
=item1 Test on msg filter with Regex
=item1 Test if category package is correctly set to caller package name (class)
=item1 Test on category filter with Str
=item1 Test on category filter with Regex
=item1 Test severity filters (exact match, array matches, operators matches)
=end pod

use Test;

plan 20;

use Log::Any;
use Log::Any::Adapter;

class AdapterDebug is Log::Any::Adapter {
	has @.logs;
	method handle( $msg ) {
		push @!logs, $msg;
	}
}

my $a = AdapterDebug.new;


# MSG
# msg filter on Str
Log::Any.add( $a, :filter( [msg => 'msgfilter'] ) );

Log::Any.info( 'does not match' );
is $a.logs.elems, 0, '"does not match" does not match "msgfilter"';

Log::Any.info( 'msgfilter' );
is $a.logs.elems, 1, '"msgfilter" match "msgfilter"';

Log::Any.info( 'begin msgfilter' );
is $a.logs.elems, 1, '"begin msgfilter" does not match "msgfilter"';
Log::Any.info( 'msgfilter end' );
is $a.logs.elems, 1, '"msgfilter end" does not match "msgfilter"';


# msg filter on regex
$a.logs = [];
Log::Any.add( $a, :filter( [ msg => /msgfilter/] ), pipeline => 'msg regex filter' );

Log::Any.info( 'does not match', pipeline => 'msg regex filter' );
is $a.logs.elems, 0, '"does not match" does not match /msgfilter/';

Log::Any.info( 'msgfilter', :pipeline('msg regex filter') );
is $a.logs.elems, 1, '"msgfilter" match /msgfilter/';

Log::Any.info( 'begin msgfilter', :pipeline('msg regex filter') );
is $a.logs[*-1], 'begin msgfilter', '"begin msgfilter" match /msgfilter/';
Log::Any.info( 'msgfilter end', :pipeline('msg regex filter') );
is $a.logs[*-1], 'msgfilter end', '"msgfilter end" match /msgfilter/';


# CATEGORY
# get caller class name

class Foo {
	method foo( $pipeline ) {
		Log::Any.info( 'msg from Foo::foo', :pipeline( $pipeline ) );
	}

	method get-method( $pipeline ) {
		return { Log::Any.info( 'msg from Foo::get-method', :pipeline( $pipeline ) ) };
	}
}

class Bar {
	method bar( $pipeline ) {
		my &met = Foo.get-method( $pipeline );
		&met();
	}
}

$a.logs = [];
Log::Any.add( $a, :formatter( '\c \m' ), :pipeline('caller category') );

Foo.foo( 'caller category' );
is $a.logs[*-1], 'Foo msg from Foo::foo', 'Direct call from Foo::foo';

Bar.bar( 'caller category' );
is $a.logs[*-1], 'Bar msg from Foo::get-method', 'Indirect call from Bar::bar';

# category filter on Str

$a .= new;
my $b = AdapterDebug.new;
Log::Any.add(
	$a,
	:filter( [ :category( 'Foo' ) ] ),
	:pipeline('filter on caller category'),
	:formatter( '\c \m' )
);
Log::Any.add(
	$b,
	:pipeline( 'filter on caller category' ),
	:formatter( '\c \m' )
);

Foo.foo( 'filter on caller category' );
Bar.bar( 'filter on caller category' );

is $a.logs[*-1], 'Foo msg from Foo::foo', 'Category filtering';
is $b.logs[*-1], 'Bar msg from Foo::get-method', 'Category filtering';

# category filter on regex

# SEVERITY

$a .= new;
Log::Any.add( $a, :pipeline( 'filter on severity' ), :filter( [ severity => 'info' ] ) );

# Only the first log should be present in the Adapter
Log::Any.info(      :pipeline( 'filter on severity' ), 'info severity'      );
Log::Any.trace(     :pipeline( 'filter on severity' ), 'trace severity'     );
Log::Any.debug(     :pipeline( 'filter on severity' ), 'debug severity'     );
Log::Any.notice(    :pipeline( 'filter on severity' ), 'notice severity'    );
Log::Any.warning(   :pipeline( 'filter on severity' ), 'warning severity'   );
Log::Any.error(     :pipeline( 'filter on severity' ), 'error severity'     );
Log::Any.critical(  :pipeline( 'filter on severity' ), 'critical severity'  );
Log::Any.alert(     :pipeline( 'filter on severity' ), 'alert severity'     );
Log::Any.emergency( :pipeline( 'filter on severity' ), 'emergency severity' );

is $a.elems == 1 && $a.logs[*-1], 'info severity', 'filter on severity == info';


# Test if the severity is above notice
$a .= new;
$b .= new;
Log::Any.add( $a, :pipeline( 'filter on severity' ), :filter( [ severity => '>notice' ] ) );
Log::Any.add( $b, :pipeline( 'filter on severity' ), :filter( [ severity => '<=notice' ] ) );

Log::Any.trace(     :pipeline( 'filter on severity' ), 'trace severity'     );
Log::Any.debug(     :pipeline( 'filter on severity' ), 'debug severity'     );
Log::Any.info(      :pipeline( 'filter on severity' ), 'info severity'      );
Log::Any.notice(    :pipeline( 'filter on severity' ), 'notice severity'    );
Log::Any.warning(   :pipeline( 'filter on severity' ), 'warning severity'   );
Log::Any.error(     :pipeline( 'filter on severity' ), 'error severity'     );
Log::Any.critical(  :pipeline( 'filter on severity' ), 'critical severity'  );
Log::Any.alert(     :pipeline( 'filter on severity' ), 'alert severity'     );
Log::Any.emergency( :pipeline( 'filter on severity' ), 'emergency severity' );

is $a.logs, ['warning severity', 'error severity', 'critical severity', 'alert severity', 'emergency severity'], 'filter on severity > notice';
is $b.logs, ['trace severity', 'debug severity', 'notice severity'], 'filter on severity <= notice';

$a .= new;
$b .= new;
my $c = AdapterDebug.new;
# Test when severity filter is an array
Log::Any.add( $a, :pipeline( 'filter on severity array' ), :filter( [ severity => [ 'debug'                      ] ] ) );
Log::Any.add( $b, :pipeline( 'filter on severity array' ), :filter( [ severity => [ 'info',  'emergency'         ] ] ) );
Log::Any.add( $c, :pipeline( 'filter on severity array' ), :filter( [ severity => [ 'trace', 'critical', 'alert', 'error', 'warning', 'notice'] ] ) );

Log::Any.trace(     :pipeline( 'filter on severity array' ), 'trace severity'     );
Log::Any.debug(     :pipeline( 'filter on severity array' ), 'debug severity'     );
Log::Any.info(      :pipeline( 'filter on severity array' ), 'info severity'      );
Log::Any.notice(    :pipeline( 'filter on severity array' ), 'notice severity'    );
Log::Any.warning(   :pipeline( 'filter on severity array' ), 'warning severity'   );
Log::Any.error(     :pipeline( 'filter on severity array' ), 'error severity'     );
Log::Any.critical(  :pipeline( 'filter on severity array' ), 'critical severity'  );
Log::Any.alert(     :pipeline( 'filter on severity array' ), 'alert severity'     );
Log::Any.emergency( :pipeline( 'filter on severity array' ), 'emergency severity' );

is $a.logs,
	['debug severity'],
	'filter on severity array [debug]';
is $b.logs,
	['info severity', 'emergency severity'],
	'filter on severity array [info, emergency]';
is $c.logs,
	['trace severity', 'notice severity', 'warning severity', 'error severity', 'critical severity', 'alert severity' ],
	'filter on severity array [trace,critical,alert,error,warning,notice]';

# BARRIER FILTERS

$a .= new;
Log::Any.add( :filter( [severity => '>info'] ), :pipeline( 'filter barrier' ) );
Log::Any.add( $a, :pipeline( 'filter barrier' ) );

Log::Any.trace(     :pipeline( 'filter barrier' ), 'trace severity'     );
Log::Any.debug(     :pipeline( 'filter barrier' ), 'debug severity'     );
Log::Any.info(      :pipeline( 'filter barrier' ), 'info severity'      );
Log::Any.notice(    :pipeline( 'filter barrier' ), 'notice severity'    );
Log::Any.warning(   :pipeline( 'filter barrier' ), 'warning severity'   );
Log::Any.error(     :pipeline( 'filter barrier' ), 'error severity'     );
Log::Any.critical(  :pipeline( 'filter barrier' ), 'critical severity'  );
Log::Any.alert(     :pipeline( 'filter barrier' ), 'alert severity'     );
Log::Any.emergency( :pipeline( 'filter barrier' ), 'emergency severity' );

is $a.logs, ['trace severity', 'debug severity', 'info severity'], 'filter barrier blocks severity>info';

# MULTIPLE FILTERS

$a .= new;
Log::Any.add( $a, :pipeline( 'multi filter' ), :filter( [msg => /abc/, category => 'multi', severity => '=error' ] ) );

Log::Any.info( 'zabcd', :pipeline( 'multi filter' ), category => 'multi' );
Log::Any.error( 'zzzz', :pipeline( 'multi filter' ), category => 'multi' );
Log::Any.error( 'abc', :pipeline( 'multi filter' ), category => 'solo' );
Log::Any.error( 'abcd', :pipeline( 'multi filter' ), category => 'multi' );

is $a.logs, ['abcd'], 'multi filters ok';
