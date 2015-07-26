# Rakudo::Perl6::Tracer

Trace Perl6 code.

Known limitations: if there is a `BEGIN`, there will not be any formatting.
Also, if classes are imported from nqp.


## Usage

    use Rakudo::Perl6::Tracer;

    my $f = Rakudo::Perl6::Tracer.new(); # create a new object
    say $f.trace({},$content); #  trace the content

The returned program code will contain tracing statements beside the
original code.

If you run the traced code, you will see what lines were executed.

## Command line access

    $ perl6 trace.p6 -h

    $ perl6 trace.p6  <Dagrammar.p6 >traced.p6
    $ perl6 trace.p6 -sl  <Dagrammar.p6 >traced.p6

## Example

Example of traced code, note statements are inserted by `trace.p6`:

    sub dump_node($node)
    {
     note "line  19";say "matched";
     note "line  20";if ($node<regliteral>) {
     note "line  21";say "reg $node"~$node<regliteral>;
     note "line  22";}
    note "line  23";}

OR example trace log with -sl

    line  1 my @Depindex;
    line  2 my @Depthis;
    line  3 my @Depon;
    line  4 my @Depend;
    line  5 my @Bot;
    line  7 my $debug = False;
    line  215 my %h;
    line  216 my %g;
    line  217 %h<itemid> = 1;
    line  218 %g<itemid> = 2;
    line  219 %h<name>   = '1';
    line  220 %g<name>   = '2';
    line  222 my %j  = ( "itemid", 3, "name", 3 );
    line  223 my %j4 = ( "itemid", 4, "name", 4 );
