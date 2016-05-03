use v6;
use Digest::xxHash;
use X::TXN::Parser;
unit class TXN::Parser::Actions;

# DateTime offset for when the local offset is omitted in dates. if
# not passed as a parameter during instantiation, use UTC
has Int $.date-local-offset = 0;

# increments on each entry (0+)
has UInt $!entry-number = 0;

subset Quantity of FatRat where * >= 0;

# string grammar-actions {{{

# --- string basic grammar-actions {{{

method string-basic-char:common ($/)
{
    make ~$/;
}

method string-basic-char:tab ($/)
{
    make ~$/;
}

method escape:sym<b>($/)
{
    make "\b";
}

method escape:sym<t>($/)
{
    make "\t";
}

method escape:sym<n>($/)
{
    make "\n";
}

method escape:sym<f>($/)
{
    make "\f";
}

method escape:sym<r>($/)
{
    make "\r";
}

method escape:sym<quote>($/)
{
    make "\"";
}

method escape:sym<backslash>($/)
{
    make '\\';
}

method escape:sym<u>($/)
{
    make chr :16(@<hex>.join);
}

method escape:sym<U>($/)
{
    make chr :16(@<hex>.join);
}

method string-basic-char:escape-sequence ($/)
{
    make $<escape>.made;
}

method string-basic-text($/)
{
    make @<string-basic-char>».made.join;
}

method string-basic($/)
{
    make $<string-basic-text> ?? $<string-basic-text>.made !! "";
}

method string-basic-multiline-char:common ($/)
{
    make ~$/;
}

method string-basic-multiline-char:tab ($/)
{
    make ~$/;
}

method string-basic-multiline-char:newline ($/)
{
    make ~$/;
}

method string-basic-multiline-char:escape-sequence ($/)
{
    if $<escape>
    {
        make $<escape>.made;
    }
    elsif $<ws-remover>
    {
        make "";
    }
}

method string-basic-multiline-text($/)
{
    make @<string-basic-multiline-char>».made.join;
}

method string-basic-multiline($/)
{
    make $<string-basic-multiline-text>
        ?? $<string-basic-multiline-text>.made
        !! "";
}

# --- end string basic grammar-actions }}}
# --- string literal grammar-actions {{{

method string-literal-char:common ($/)
{
    make ~$/;
}

method string-literal-char:backslash ($/)
{
    make '\\';
}

method string-literal-text($/)
{
    make @<string-literal-char>».made.join;
}

method string-literal($/)
{
    make $<string-literal-text> ?? $<string-literal-text>.made !! "";
}

method string-literal-multiline-char:common ($/)
{
    make ~$/;
}

method string-literal-multiline-char:backslash ($/)
{
    make '\\';
}

method string-literal-multiline-text($/)
{
    make @<string-literal-multiline-char>».made.join;
}

method string-literal-multiline($/)
{
    make $<string-literal-multiline-text>
        ?? $<string-literal-multiline-text>.made
        !! "";
}

# --- end string literal grammar-actions }}}

method string:basic ($/)
{
    make $<string-basic>.made;
}

method string:basic-multi ($/)
{
    make $<string-basic-multiline>.made;
}

method string:literal ($/)
{
    make $<string-literal>.made;
}

method string:literal-multi ($/)
{
    make $<string-literal-multiline>.made;
}

# end string grammar-actions }}}
# number grammar-actions {{{

method integer-unsigned($/)
{
    # ensure integers are coerced to type FatRat
    make FatRat(+$/);
}

method float-unsigned($/)
{
    make FatRat(+$/);
}

method plus-or-minus:sym<+>($/)
{
    make ~$/;
}

method plus-or-minus:sym<->($/)
{
    make ~$/;
}

# end number grammar-actions }}}
# datetime grammar-actions {{{

method date-fullyear($/)
{
    make Int(+$/);
}

method date-month($/)
{
    make Int(+$/);
}

method date-mday($/)
{
    make Int(+$/);
}

method time-hour($/)
{
    make Int(+$/);
}

method time-minute($/)
{
    make Int(+$/);
}

method time-second($/)
{
    make Rat(+$/);
}

method time-secfrac($/)
{
    make Rat(+$/);
}

method time-numoffset($/)
{
    my Int $multiplier = $<plus-or-minus> ~~ '+' ?? 1 !! -1;
    make Int(
        (
            ($multiplier * $<time-hour>.made * 60) + $<time-minute>.made
        )
        * 60
    );
}

method time-offset($/)
{
    make $<time-numoffset> ?? Int($<time-numoffset>.made) !! 0;
}

method partial-time($/)
{
    my Rat $second = Rat($<time-second>.made);
    $second += Rat($<time-secfrac>.made) if $<time-secfrac>;
    make %(
        :hour(Int($<time-hour>.made)),
        :minute(Int($<time-minute>.made)),
        :$second
    );
}

method full-date($/)
{
    make %(
        :year(Int($<date-fullyear>.made)),
        :month(Int($<date-month>.made)),
        :day(Int($<date-mday>.made))
    );
}

method full-time($/)
{
    make %(
        :hour(Int($<partial-time>.made<hour>)),
        :minute(Int($<partial-time>.made<minute>)),
        :second(Rat($<partial-time>.made<second>)),
        :timezone(Int($<time-offset>.made))
    );
}

method date-time-omit-local-offset($/)
{
    make DateTime.new(
        :year(Int($<full-date>.made<year>)),
        :month(Int($<full-date>.made<month>)),
        :day(Int($<full-date>.made<day>)),
        :hour(Int($<partial-time>.made<hour>)),
        :minute(Int($<partial-time>.made<minute>)),
        :second(Rat($<partial-time>.made<second>)),
        :timezone($.date-local-offset)
    );
}

method date-time($/)
{
    make DateTime.new(
        :year(Int($<full-date>.made<year>)),
        :month(Int($<full-date>.made<month>)),
        :day(Int($<full-date>.made<day>)),
        :hour(Int($<full-time>.made<hour>)),
        :minute(Int($<full-time>.made<minute>)),
        :second(Rat($<full-time>.made<second>)),
        :timezone(Int($<full-time>.made<timezone>))
    );
}

method date:full-date ($/)
{
    make DateTime.new(|$<full-date>.made, :timezone($.date-local-offset));
}

method date:date-time-omit-local-offset ($/)
{
    make $<date-time-omit-local-offset>.made;
}

method date:date-time ($/)
{
    make $<date-time>.made;
}

# end datetime grammar-actions }}}
# variable name grammar-actions {{{

method var-name:bare ($/)
{
    make ~$/;
}

method var-name-string:basic ($/)
{
    make $<string-basic-text>.made;
}

method var-name-string:literal ($/)
{
    make $<string-literal-text>.made;
}

method var-name:quoted ($/)
{
    make $<var-name-string>.made;
}

# end variable name grammar-actions }}}
# header grammar-actions {{{

method important($/)
{
    # make important the quantity of exclamation marks
    make $/.chars;
}

method tag($/)
{
    # make tag (with leading @ stripped)
    make $<var-name>.made;
}

method meta:important ($/)
{
    make %(important => $<important>.made);
}

method meta:tag ($/)
{
    make %(tag => $<tag>.made);
}

method metainfo($/)
{
    make @<meta>».made;
}

method description($/)
{
    make $<string>.made;
}

method header($/)
{
    # entry date
    my DateTime $date = $<date>.made;

    # entry description
    my Str $description = '';
    $description = $<description>.made if $<description>;

    # entry importance
    my UInt $important = 0;

    # entry tags
    my Str @tags;

    for @<metainfo>».made -> @metainfo
    {
        $important += [+] @metainfo.grep({ .keys ~~ 'important' })».values.flat;
        push @tags, |@metainfo.grep({ .keys ~~ 'tag' })».values.flat.unique;
    }

    # make entry header container
    make %(:$date, :$description, :$important, :@tags);
}

# end header grammar-actions }}}
# posting grammar-actions {{{

# --- posting account grammar-actions {{{

method acct-name($/)
{
    make @<var-name>».made;
}

method silo:assets ($/)
{
    make 'ASSETS';
}

method silo:expenses ($/)
{
    make 'EXPENSES';
}

method silo:income ($/)
{
    make 'INCOME';
}

method silo:liabilities ($/)
{
    make 'LIABILITIES';
}

method silo:equity ($/)
{
    make 'EQUITY';
}

method account($/)
{
    my %account;

    # silo (assets, expenses, income, liabilities, equity)
    %account<silo> = $<silo>.made;

    # entity
    %account<entity> = $<entity>.made;

    # subaccount
    %account<subaccount> = $<account-sub>.made if $<account-sub>;

    # make account
    make %account;
}

# --- end posting account grammar-actions }}}
# --- posting amount grammar-actions {{{

method asset-code:bare ($/)
{
    make ~$/;
}

method asset-code:quoted ($/)
{
    make $<var-name-string>.made;
}

method asset-symbol($/)
{
    make ~$/;
}

method asset-quantity:integer ($/)
{
    make $<integer-unsigned>.made;
}

method asset-quantity:float ($/)
{
    make $<float-unsigned>.made;
}

method xe-main($/)
{
    # asset code
    my Str $asset-code = $<asset-code>.made;

    # asset quantity
    my Quantity $asset-quantity = $<asset-quantity>.made;

    # asset symbol
    my Str $asset-symbol = '';
    $asset-symbol = $<asset-symbol>.made if $<asset-symbol>;

    # make exchange rate
    make %(:$asset-code, :$asset-quantity, :$asset-symbol);
}

method xe-secondary($/)
{
    make $<sxe>.made;
}

method xe($/)
{
    my %xe = $<xe-main>.made;
    %xe<xe-secondary> = $<xe-secondary>.made if $<xe-secondary>;
    make %xe;
}

method exchange-rate($/)
{
    make $<xe>.made;
}

method amount($/)
{
    # asset code
    my Str $asset-code = $<asset-code>.made;

    # asset quantity
    my Quantity $asset-quantity = $<asset-quantity>.made;

    # asset symbol
    my Str $asset-symbol = '';
    $asset-symbol = $<asset-symbol>.made if $<asset-symbol>;

    # minus sign
    my Str $plus-or-minus = '';
    $plus-or-minus = $<plus-or-minus>.made if $<plus-or-minus>;

    # exchange rate
    my %exchange-rate;
    %exchange-rate = $<exchange-rate>.made if $<exchange-rate>;

    # make amount
    make %(
        :$asset-code,
        :$asset-quantity,
        :$asset-symbol,
        :$plus-or-minus,
        :%exchange-rate
    );
}

# --- end posting amount grammar-actions }}}

method posting($/)
{
    my Str $text = $/.Str;

    # account
    my %account = $<account>.made;

    # amount
    my %amount = $<amount>.made;

    # dec / inc
    my Str $decinc = mkdecinc(%amount<plus-or-minus>);

    # xxHash of transaction journal posting text
    my UInt $xxhash = xxHash32($text);

    # make posting container
    make %(:%account, :%amount, :$decinc, :$text, :$xxhash);
}

method posting-line:content ($/)
{
    make $<posting>.made;
}

method postings($/)
{
    make @<posting-line>».made.grep(Hash);
}

# end posting grammar-actions }}}
# include grammar-actions {{{

method filename($/)
{
    make $<var-name-string>.made;
}

method include($/)
{
    # relative path to transaction journal with .txn extension appended
    make $<filename>.made ~ ".txn";
}

method include-line($/)
{
    make $<include>.made;
}

# end include grammar-actions }}}
# extends grammar-actions {{{

method extends($/)
{
    my Str $filename = $<filename>.made;
    unless $filename.IO.e && $filename.IO.r
    {
        die X::TXN::Parser::Extends.new(:$filename);
    }
    make $filename;
}

method extends-line($/)
{
    make $<extends>.made;
}

# end extends grammar-actions }}}
# journal grammar-actions {{{

method entry($/)
{
    my Str $text = $/.Str;

    my @postings = $<postings>.made;

    # verify entry is limited to one entity
    {
        my Str @entities;
        push @entities, $_<account><entity> for @postings;

        # is the number of elements sharing the same entity name not equal
        # to the total number of entity names seen?
        unless @entities.grep(@entities[0]).elems == @entities.elems
        {
            # error: invalid use of more than one entity per journal entry
            die X::TXN::Parser::Entry::MultipleEntities.new(
                :number-entities(@entities.elems),
                :entry-text($text)
            );
        }
    }

    # xxHash of transaction journal entry text
    my UInt $xxhash = xxHash32($text);

    my %entry-id = :number($!entry-number++), :$xxhash, :$text;

    # insert PostingID derived from EntryID into postings
    my UInt $posting-number = 0;
    @postings .= map({
        %(
            :account($_<account>),
            :amount($_<amount>),
            :decinc($_<decinc>),
            :id(%(
                :%entry-id,
                :number($posting-number++),
                :xxhash($_<xxhash>),
                :text($_<text>);
            ))
        )
    });

    make %(:id(%entry-id), :header($<header>.made), :@postings);
}

method segment:entry ($/)
{
    make $<entry>.made;
}

method journal($/)
{
    my @entries = @<segment>».made.grep(Hash);
    make @entries;
}

method TOP($/)
{
    make $<journal>.made;
}

# end journal grammar-actions }}}

# helper functions {{{

sub mkasset-flow(FatRat:D $d) returns Str:D
{
    if $d > 0
    {
        'ACQUIRE';
    }
    elsif $d < 0
    {
        'EXPEND';
    }
    else
    {
        'STABLE';
    }
}

sub mkdecinc(Str $plus-or-minus) returns Str:D
{
    $plus-or-minus ~~ '-' ?? 'DEC' !! 'INC';
}

# end helper functions }}}

# vim: ft=perl6 fdm=marker fdl=0
