# Perl6::Tracer

Trace Perl6 code.

Known limitations: if there is a `BEGIN`, there will not be any formatting.
Also, if classes are imported from nqp.


## Usage

    use Perl6::Tracer;

    my $f = Perl6::Tracer.new(); # create a new object
    say $f.trace({},$content); #  trace the content

The returned program code will contain tracing statements beside the
original code.

If you run the traced code, you will see what lines were executed.

## Command line access

    $ perl6 trace.p6 -h

    $ perl6 trace.p6 4 <Dagrammar.p6 >traced.p6

## Example

Example of traced code, note statements are inserted by `trace.p6`:

    sub dump_node($node)
    {
     note "line  19";say "matched";
     note "line  20";if ($node<regliteral>) {
     note "line  21";say "reg $node"~$node<regliteral>;
     note "line  22";}
    note "line  23";}
