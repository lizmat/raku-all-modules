use lib 'lib';
use Test;
use PodCache::Render;
use PodCache::Processed;
use File::Directory::Tree;

plan 7;
diag "lists, placement";

my $fn = 'lists-test-pod-file_0';

constant REP = 't/tmp/rep';
constant DOC = 't/tmp/doc';
constant OUTPUT = 't/tmp/html';

mktree OUTPUT unless OUTPUT.IO ~~ :d;
my PodCache::Processed $pr;

sub cache_test(Str $fn is copy, Str $to-cache --> PodCache::Processed ) {
    (DOC ~ "/$fn.pod6").IO.spurt: $to-cache;
    my PodCache::Render $ren .= new(:path( REP ), :output( OUTPUT ) );
    $ren.update-cache;
    $ren.processed-instance( :name($fn) );
}

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin pod
    The seven suspects are:

    =item  Happy
    =item  Dopey
    =item  Sleepy
    =item  Bashful
    =item  Sneezy
    =item  Grumpy
    =item  Keyser Soze

    We want to know the first through the door.
    =end pod
    PODEND

#--MARKER-- Test 1
like $pr.pod-body.subst(/\s+/,' ',:g).trim, /
    '<section name="___top">'
    \s*'<p>The seven suspects are:</p>'
    \s* '<ul>'
    \s* '<li>' \s* '<p>Happy</p>' \s* '</li>'
    \s* '<li>' \s* '<p>Dopey</p>' \s* '</li>'
    \s* '<li>' \s* '<p>Sleepy</p>' \s* '</li>'
    \s* '<li>' \s* '<p>Bashful</p>' \s* '</li>'
    \s* '<li>' \s* '<p>Sneezy</p>' \s* '</li>'
    \s* '<li>' \s* '<p>Grumpy</p>' \s* '</li>'
    \s* '<li>' \s* '<p>Keyser Soze</p>' \s* '</li>'
    \s* '</ul>'
    \s* '<p>We want to know the first through the door.</p>'
    \s* '</section>'
    /, 'simple list ok';

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin pod
    =item1  Animal
    =item2     Vertebrate
    =item2     Invertebrate

    =item1  Phase
    =item2     Solid
    =item2     Liquid
    =item2     Gas
    =item2     Chocolate
    =end pod

    PODEND

#--MARKER-- Test 2
like $pr.pod-body.subst(/\s+/,' ',:g).trim,
    /
    '<ul>'
    \s* '<li>' \s* '<p>Animal</p>' \s* '</li>'
    \s* '<ul>'
    \s*     '<li>' \s* '<p>Vertebrate</p>' \s* '</li>'
    \s*     '<li>' \s* '<p>Invertebrate</p>' \s* '</li>'
    \s* '</ul>'
    \s* '<li>' \s* '<p>Phase</p>' \s* '</li>'
    \s* '<ul>'
    \s*     '<li>' \s* '<p>Solid</p>' \s* '</li>'
    \s*     '<li>' \s* '<p>Liquid</p>' \s* '</li>'
    \s*     '<li>' \s* '<p>Gas</p>' \s* '</li>'
    \s*     '<li>' \s* '<p>Chocolate</p>' \s* '</li>'
    \s* '</ul>'
    \s* '</ul>'
    /, 'multi-layer list';

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin pod
    =comment CORRECT...
    =begin item1
    The choices are:
    =end item1
    =item2 Liberty
    =item2 Death
    =item2 Beer
    =end pod
    PODEND

#--MARKER-- Test 3
like $pr.pod-body.subst(/\s+/,' ',:g).trim,
    /
    '<ul>'
    \s* '<li>' \s* '<p>The choices are:</p>' \s* '</li>'
    \s* '<ul>'
    \s*     '<li>' \s* '<p>Liberty</p>' \s* '</li>'
    \s*     '<li>' \s* '<p>Death</p>' \s* '</li>'
    \s*     '<li>' \s* '<p>Beer</p>' \s* '</li>'
    \s* '</ul>'
    \s* '</ul>'
    /, 'hierarchical unordered list';

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin pod
    =comment CORRECT...
    =begin item1
    The choices are:
    =end item1
    =item2 Liberty
    =item2 Death
    =item2 Beer
    =item4 non-alcoholic
    =end pod
    PODEND

#--MARKER-- Test 4
like $pr.pod-body.subst(/\s+/,' ',:g).trim,
    /
    '<ul>'
    \s* '<li>' \s* '<p>The choices are:</p>' \s* '</li>'
    \s* '<ul>'
    \s*     '<li>' \s* '<p>Liberty</p>' \s* '</li>'
    \s*     '<li>' \s* '<p>Death</p>' \s* '</li>'
    \s*     '<li>' \s* '<p>Beer</p>' \s* '</li>'
    \s*    '<ul>'
    \s*         '<ul>'
    \s*             '<li>' \s* '<p>non-alcoholic</p>' \s* '</li>'
    \s*         '</ul>'
    \s*     '</ul>'
    \s* '</ul>'
    \s* '</ul>'
    /, 'hierarchical unordered list, empty level';

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin pod
    Let's consider two common proverbs:

    =begin item
    I<The rain in Spain falls mainly on the plain.>

    This is a common myth and an unconscionable slur on the Spanish
    people, the majority of whom are extremely attractive.
    =end item

    =begin item
    I<The early bird gets the worm.>

    In deciding whether to become an early riser, it is worth
    considering whether you would actually enjoy annelids
    for breakfast.
    =end item

    As you can see, folk wisdom is often of dubious value.
    =end pod
    PODEND

#--MARKER-- Test 5
like $pr.pod-body.subst(/\s+/,' ',:g).trim,
    /
    '<p>Let\'s consider two common proverbs:</p>'
    \s* '<ul>'
    \s*     '<li>'
    \s*         '<p>' \s* '<em>The rain in Spain falls mainly on the plain.</em>' \s* '</p>'
    \s*         '<p>This is a common myth and an unconscionable slur on the Spanish people, the majority of whom are extremely attractive.</p>'
    \s*     '</li>'
    \s*     '<li>'
    \s*         '<p>' \s* '<em>The early bird gets the worm.</em>' \s* '</p>'
    \s*         '<p>In deciding whether to become an early riser, it is worth considering whether you would actually enjoy annelids for breakfast.</p>'
    \s*     '</li>'
    \s* '</ul>'
    \s* '<p>As you can see, folk wisdom is often of dubious value.</p>'
    /, 'List with embedded paragraphs';

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin pod
    In Perl 5, the ampersand sigil can additionally be used to call subroutines ...

    =begin item
    C<&foo(...)> I<for circumventing a function prototype>

    In Perl 6 there are no prototypes, and it no longer ...

    =for code :lang<perl5>
    # Perl 5:
    first_index { $_ > 5 } @values;
    &first_index($coderef, @values); # (disabling the prototype that parses a
                                         # literal block as the first argument)
    =for code :preamble<my @values; my $coderef>
    # Perl 6:
    first { $_ > 5 }, @values, :k;   # the :k makes first return an index
    first $coderef, @values, :k;
    =end item

    =begin item
    C<&foo;> I<and> C<goto &foo;> I<for re-using the caller's argument
    list / replacing the caller in the call stack>. Perl 6 can use either
    L<C<callsame>|/language/functions#index-entry-dispatch_callsame> for
    re-dispatching or
    L<C<nextsame>|/language/functions#index-entry-dispatch_nextsame> and
    L<C<nextwith>|/language/functions#index-entry-dispatch_nextwith>, which have no
    exact equivalent in Perl 5.

    =for code :lang<perl5>
    sub foo { say "before"; &bar;     say "after" } # Perl 5

    =for code :preamble<sub bar() {...}>
    sub foo { say "before"; bar(|@_); say "after" } # Perl 6 - have to be explicit

    =for code :lang<perl5>
    sub foo { say "before"; goto &bar } # Perl 5
    =begin code
    proto foo (|) {*};
    multi foo ( Any $n ) {
        say "Any"; say $n;
    };
    multi foo ( Int $n ) {
        say "Int"; callsame;
    };
    foo(3); # /language/functions#index-entry-dispatch_callsame
    =end code

    =end item

    =head3 C<*> Glob
    =end pod
    PODEND

#--MARKER-- Test 6
like $pr.pod-body.subst(/\s+/,' ',:g).trim,
    /
    '<p>In Perl&nbsp;5, the ampersand sigil can additionally be used to call subroutines'
    .+ '<ul>'
    \s* '<li>'
    .+ 'for circumventing'
    .+ '</li>'
    \s* '<li>'
    .+ 'for re-using'
    .+ '</li>'
    \s* '</ul>'
    \s* '<h3 id="*_glob">'
    \s* '<a href="'
    .+ 'class="u" title="go to top of document"><code>*</code>'
    \s* 'Glob</a></h3>'
    /, 'List followed by Header with embedded POD';

# Placements
# These examples are adapted from pod.pod6 :)

't/tmp/disclaimernotice'.IO.spurt: q:to/COPYEND/;
    ABSOLUTELY NO WARRANTY IS IMPLIED. NOT EVEN OF ANY KIND. WE HAVE SOLD
    YOU THIS SOFTWARE WITH NO HINT OF A SUGGESTION THAT IT IS EITHER USEFUL
    OR USABLE. AS FOR GUARANTEES OF CORRECTNESS...DON'T MAKE US LAUGH! AT
    SOME TIME IN THE FUTURE WE MIGHT DEIGN TO SELL YOU UPGRADES THAT PURPORT
    TO ADDRESS SOME OF THE APPLICATION'S MANY DEFICIENCIES, BUT NO PROMISES
    THERE EITHER. WE HAVE MORE LAWYERS ON STAFF THAN YOU HAVE TOTAL
    EMPLOYEES, SO DON'T EVEN *THINK* ABOUT SUING US. HAVE A NICE DAY.
    COPYEND

$pr = cache_test(++$fn, q:to/PODEND/);
    =begin pod

    =COPYRIGHT
    P<https://raw.githubusercontent.com/rakudo/rakudo/master/LICENSE>

    =DISCLAIMER
    P<file:t/tmp/disclaimernotice>

    =DOCUMENTS
    P<https://doc.perl6.org>

    =end pod
    PODEND

#--MARKER-- Test 7
like $pr.pod-body.subst(/\s+/,' ',:g).trim,
        /
            'Artistic License 2.0'
            .+
            'ABSOLUTELY NO WARRANTY IS IMPLIED'
            .+
            'Perl' \s '6 Documentation'
        /, 'Seems to have got all three docs';