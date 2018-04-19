use v6;
use Digest::xxHash;
use TXN::Parser::Grammar;
use TXN::Parser::ParseTree;
use TXN::Parser::Types;
use X::TXN::Parser;
unit class TXN::Parser::Actions;

# public attributes {{{

# base path for <include> directives
has Str:D $.include-lib = '/usr/include/txn';

# DateTime offset for when the local offset is omitted in dates. if
# not passed as a parameter during instantiation, use UTC (0)
has Int:D $.date-local-offset = 0;

# increments on each entry (0+)
# each element in list represents an include level deep (0+)
has UInt:D @.entry-number = 0;

# the file currently being parsed
has Str:D $.file = '.';

# end public attributes }}}
# private types {{{

# to aid with building exchange rates (@ and @@, « and ««)
my enum XERateType <PER-UNIT IN-TOTAL>;

# end private types }}}

# string grammar-actions {{{

# --- string basic grammar-actions {{{

method string-basic-char:common ($/ --> Nil)
{
    make(~$/);
}

method string-basic-char:tab ($/ --> Nil)
{
    make(~$/);
}

method escape:sym<b>($/ --> Nil)
{
    make("\b");
}

method escape:sym<t>($/ --> Nil)
{
    make("\t");
}

method escape:sym<n>($/ --> Nil)
{
    make("\n");
}

method escape:sym<f>($/ --> Nil)
{
    make("\f");
}

method escape:sym<r>($/ --> Nil)
{
    make("\r");
}

method escape:sym<quote>($/ --> Nil)
{
    make("\"");
}

method escape:sym<backslash>($/ --> Nil)
{
    make('\\');
}

method escape:sym<u>($/ --> Nil)
{
    make(chr(:16(@<hex>.join)));
}

method escape:sym<U>($/ --> Nil)
{
    make(chr(:16(@<hex>.join)));
}

method string-basic-char:escape-sequence ($/ --> Nil)
{
    make($<escape>.made);
}

method string-basic-text($/ --> Nil)
{
    make(@<string-basic-char>.hyper.map({ .made }).join);
}

multi method string-basic($/ where $<string-basic-text>.so --> Nil)
{
    make($<string-basic-text>.made);
}

multi method string-basic($/ --> Nil)
{
    make('');
}

method string-basic-multiline-char:common ($/ --> Nil)
{
    make(~$/);
}

method string-basic-multiline-char:tab ($/ --> Nil)
{
    make(~$/);
}

method string-basic-multiline-char:newline ($/ --> Nil)
{
    make(~$/);
}

multi method string-basic-multiline-char:escape-sequence (
    $/ where $<escape>.so
    --> Nil
)
{
    make($<escape>.made);
}

multi method string-basic-multiline-char:escape-sequence (
    $/ where $<ws-remover>.so
    --> Nil
)
{
    make('');
}

method string-basic-multiline-text($/ --> Nil)
{
    make(@<string-basic-multiline-char>.hyper.map({ .made }).join);
}

multi method string-basic-multiline(
    $/ where $<string-basic-multiline-text>.so
    --> Nil
)
{
    make($<string-basic-multiline-text>.made);
}

multi method string-basic-multiline($/ --> Nil)
{
    make('');
}

# --- end string basic grammar-actions }}}
# --- string literal grammar-actions {{{

method string-literal-char:common ($/ --> Nil)
{
    make(~$/);
}

method string-literal-char:backslash ($/ --> Nil)
{
    make('\\');
}

method string-literal-text($/ --> Nil)
{
    make(@<string-literal-char>.hyper.map({ .made }).join);
}

multi method string-literal($/ where $<string-literal-text>.so --> Nil)
{
    make($<string-literal-text>.made);
}

multi method string-literal($/ --> Nil)
{
    make('');
}

method string-literal-multiline-char:common ($/ --> Nil)
{
    make(~$/);
}

method string-literal-multiline-char:backslash ($/ --> Nil)
{
    make('\\');
}

method string-literal-multiline-text($/ --> Nil)
{
    make(@<string-literal-multiline-char>.hyper.map({ .made }).join);
}

multi method string-literal-multiline(
    $/ where $<string-literal-multiline-text>.so
    --> Nil
)
{
    make($<string-literal-multiline-text>.made);
}

multi method string-literal-multiline($/ --> Nil)
{
    make('');
}

# --- end string literal grammar-actions }}}
# --- var-name string grammar-actions {{{

method var-name-string:basic ($/ --> Nil)
{
    make($<string-basic-text>.made);
}

method var-name-string:literal ($/ --> Nil)
{
    make($<string-literal-text>.made);
}

# --- end var-name string grammar-actions }}}
# --- txnlib string grammar-actions {{{

method txnlib-string-delimiter-right($/ --> Nil)
{
    make(~$/);
}

method txnlib-string-path-divisor($/ --> Nil)
{
    make(~$/);
}

method txnlib-escape:sym<backslash>($/ --> Nil)
{
    make('\\');
}

method txnlib-escape:sym<delimiter-right>($/ --> Nil)
{
    make($<txnlib-string-delimiter-right>.made);
}

method txnlib-escape:sym<horizontal-ws>($/ --> Nil)
{
    make(~$/);
}

method txnlib-escape:sym<path-divisor>($/ --> Nil)
{
    make($<txnlib-string-path-divisor>.made);
}

method txnlib-string-char:common ($/ --> Nil)
{
    make(~$/);
}

method txnlib-string-char:escape-sequence ($/ --> Nil)
{
    make($<txnlib-escape>.made);
}

method txnlib-string-char:path-divisor ($/ --> Nil)
{
    make($<txnlib-string-path-divisor>.made);
}

method txnlib-string-text($/ --> Nil)
{
    make(@<txnlib-string-char>.hyper.map({ .made }).join);
}

method txnlib-string($/ --> Nil)
{
    make($<txnlib-string-text>.made);
}

# --- end txnlib string grammar-actions }}}

method string:basic ($/ --> Nil)
{
    make($<string-basic>.made);
}

method string:basic-multi ($/ --> Nil)
{
    make($<string-basic-multiline>.made);
}

method string:literal ($/ --> Nil)
{
    make($<string-literal>.made);
}

method string:literal-multi ($/ --> Nil)
{
    make($<string-literal-multiline>.made);
}

# end string grammar-actions }}}
# number grammar-actions {{{

method integer-unsigned($/ --> Nil)
{
    # ensure integers are coerced to type Rat
    make(Rat(+$/));
}

method float-unsigned($/ --> Nil)
{
    make(Rat(+$/));
}

method plus-or-minus:sym<+>($/ --> Nil)
{
    make(~$/);
}

method plus-or-minus:sym<->($/ --> Nil)
{
    make(~$/);
}

# end number grammar-actions }}}
# datetime grammar-actions {{{

method date-fullyear($/ --> Nil)
{
    make(Int(+$/));
}

method date-month($/ --> Nil)
{
    make(Int(+$/));
}

method date-mday($/ --> Nil)
{
    make(Int(+$/));
}

method time-hour($/ --> Nil)
{
    make(Int(+$/));
}

method time-minute($/ --> Nil)
{
    make(Int(+$/));
}

method time-second($/ --> Nil)
{
    make(Rat(+$/));
}

method time-secfrac($/ --> Nil)
{
    make(Rat(+$/));
}

method time-numoffset($/ --> Nil)
{
    my Int:D $multiplier = $<plus-or-minus>.made eq '+' ?? 1 !! -1;
    make(
        Int((($multiplier * $<time-hour>.made * 60) + $<time-minute>.made) * 60)
    );
}

multi method time-offset($/ where $<time-numoffset>.so --> Nil)
{
    make(Int($<time-numoffset>.made));
}

multi method time-offset($/ --> Nil)
{
    make(0);
}

method partial-time($/ --> Nil)
{
    my Rat:D $second = Rat($<time-second>.made);
    $second += Rat($<time-secfrac>.made) if $<time-secfrac>;
    make(
        %(
            :hour(Int($<time-hour>.made)),
            :minute(Int($<time-minute>.made)),
            :$second
        )
    );
}

method full-date($/ --> Nil)
{
    make(
        %(
            :year(Int($<date-fullyear>.made)),
            :month(Int($<date-month>.made)),
            :day(Int($<date-mday>.made))
        )
    );
}

method full-time($/ --> Nil)
{
    make(
        %(
            :hour(Int($<partial-time>.made<hour>)),
            :minute(Int($<partial-time>.made<minute>)),
            :second(Rat($<partial-time>.made<second>)),
            :timezone(Int($<time-offset>.made))
        )
    );
}

method date-time-omit-local-offset($/ --> Nil)
{
    make(
        %(
            :year(Int($<full-date>.made<year>)),
            :month(Int($<full-date>.made<month>)),
            :day(Int($<full-date>.made<day>)),
            :hour(Int($<partial-time>.made<hour>)),
            :minute(Int($<partial-time>.made<minute>)),
            :second(Rat($<partial-time>.made<second>)),
            :timezone($.date-local-offset)
        )
    );
}

method date-time($/ --> Nil)
{
    make(
        %(
            :year(Int($<full-date>.made<year>)),
            :month(Int($<full-date>.made<month>)),
            :day(Int($<full-date>.made<day>)),
            :hour(Int($<full-time>.made<hour>)),
            :minute(Int($<full-time>.made<minute>)),
            :second(Rat($<full-time>.made<second>)),
            :timezone(Int($<full-time>.made<timezone>))
        )
    );
}

method date:full-date ($/ --> Nil)
{
    make(Date.new(|$<full-date>.made));
}

method date:date-time-omit-local-offset ($/ --> Nil)
{
    make(DateTime.new(|$<date-time-omit-local-offset>.made));
}

method date:date-time ($/ --> Nil)
{
    make(DateTime.new(|$<date-time>.made));
}

# end datetime grammar-actions }}}
# variable name grammar-actions {{{

method var-name:bare ($/ --> Nil)
{
    make(~$/);
}

method var-name:quoted ($/ --> Nil)
{
    make($<var-name-string>.made);
}

# end variable name grammar-actions }}}
# header grammar-actions {{{

method important($/ --> Nil)
{
    # make important the quantity of exclamation marks
    make($/.chars);
}

method tag($/ --> Nil)
{
    # make tag (with leading # stripped)
    make($<var-name>.made);
}

method meta:important ($/ --> Nil)
{
    my $important = $<important>.made;
    my %made = :$important;
    make(%made);
}

method meta:tag ($/ --> Nil)
{
    my $tag = $<tag>.made;
    my %made = :$tag;
    make(%made);
}

method metainfo($/ --> Nil)
{
    my @made = @<meta>.hyper.map({ .made });
    make(@made);
}

method description($/ --> Nil)
{
    make($<string>.made);
}

method header($/ --> Nil)
{
    my %header;

    my Dateish:D $date = $<date>.made;
    my Str:D $description = $<description>.made if $<description>;
    my UInt:D $important = 0;
    my VarName:D @tag;

    @<metainfo>.hyper.map({ .made }).map(-> @metainfo {
        $important +=
            [+] @metainfo
                    .grep({ .keys eq 'important' })
                    .map({ .values })
                    .flat;
        append(
            @tag,
            |@metainfo
                .grep({ .keys eq 'tag' })
                .map({ .values })
                .flat
                .unique
        );
    });

    %header<date> = $date;
    %header<description> = $description if $description;
    %header<important> = $important if $important;

    make(Entry::Header.new(|%header, :@tag));
}

# end header grammar-actions }}}
# posting grammar-actions {{{

# --- posting account grammar-actions {{{

method account-name($/ --> Nil)
{
    my @made = @<var-name>.hyper.map({ .made });
    make(@made);
}

method silo:assets ($/ --> Nil)
{
    make(ASSETS);
}

method silo:expenses ($/ --> Nil)
{
    make(EXPENSES);
}

method silo:income ($/ --> Nil)
{
    make(INCOME);
}

method silo:liabilities ($/ --> Nil)
{
    make(LIABILITIES);
}

method silo:equity ($/ --> Nil)
{
    make(EQUITY);
}

method account($/ --> Nil)
{
    my %account;

    my Silo:D $silo = $<silo>.made;
    my VarName:D $entity = $<entity>.made;
    my VarName:D @path = $<account-path>.made if $<account-path>;

    %account<silo> = $silo;
    %account<entity> = $entity;

    make(Entry::Posting::Account.new(|%account, :@path));
}

# --- end posting account grammar-actions }}}
# --- posting amount grammar-actions {{{

method asset-code:bare ($/ --> Nil)
{
    make(~$/);
}

method asset-code:quoted ($/ --> Nil)
{
    make($<var-name-string>.made);
}

method asset-symbol($/ --> Nil)
{
    make(~$/);
}

method asset-quantity:integer ($/ --> Nil)
{
    make($<integer-unsigned>.made);
}

method asset-quantity:float ($/ --> Nil)
{
    make($<float-unsigned>.made);
}

method asset-price:integer ($/ --> Nil)
{
    make($<integer-unsigned>.made);
}

method asset-price:float ($/ --> Nil)
{
    make($<float-unsigned>.made);
}

method amount($/ --> Nil)
{
    my %amount;

    my AssetCode:D $asset-code = $<asset-code>.made;
    my Quantity:D $asset-quantity = $<asset-quantity>.made;
    my AssetSymbol:D $asset-symbol = $<asset-symbol>.made if $<asset-symbol>;
    my PlusMinus:D $plus-or-minus = $<plus-or-minus>.made if $<plus-or-minus>;

    %amount<asset-code> = $asset-code;
    %amount<asset-quantity> = $asset-quantity;
    %amount<asset-symbol> = $asset-symbol if $asset-symbol;
    %amount<plus-or-minus> = $plus-or-minus if $plus-or-minus;

    make(Entry::Posting::Amount.new(|%amount));
}

# --- end posting amount grammar-actions }}}
# --- posting annotation grammar-actions {{{

# --- --- xe grammar-actions {{{

method xe-symbol:per-unit ($/ --> Nil)
{
    make(PER-UNIT);
}

method xe-symbol:in-total ($/ --> Nil)
{
    make(IN-TOTAL);
}

method xe-rate($/ --> Nil)
{
    my %xe-rate;

    my AssetCode:D $asset-code = $<asset-code>.made;
    my Price:D $asset-price = $<asset-price>.made;
    my AssetSymbol:D $asset-symbol = $<asset-symbol>.made if $<asset-symbol>;

    %xe-rate<asset-code> = $asset-code;
    %xe-rate<asset-price> = $asset-price;
    %xe-rate<asset-symbol> = $asset-symbol if $asset-symbol;

    make(%xe-rate);
}

method xe($/ --> Nil)
{
    my %xe-rate = $<xe-rate>.made;
    my XERateType:D $rate-type = $<xe-symbol>.made;
    %xe-rate<rate-type> = $rate-type;
    make(%xe-rate);
}

# --- --- end xe grammar-actions }}}
# --- --- inherit grammar-actions {{{

method inherit-symbol:per-unit ($/ --> Nil)
{
    make(PER-UNIT);
}

method inherit-symbol:in-total ($/ --> Nil)
{
    make(IN-TOTAL);
}

method inherit($/ --> Nil)
{
    # a grammar alias, C<$<inherit-rate> comes from C<xe-rate>
    my %inherit-rate = $<inherit-rate>.made;
    my XERateType:D $rate-type = $<inherit-symbol>.made;
    %inherit-rate<rate-type> = $rate-type;
    make(%inherit-rate);
}

# --- --- end inherit grammar-actions }}}
# --- --- lot grammar-actions {{{

method lot-name($/ --> Nil)
{
    make($<var-name>.made);
}

method lot:acquisition ($/ --> Nil)
{
    my %lot;

    my VarName:D $name = $<lot-name>.made;
    my DecInc:D $decinc = INC;

    %lot<name> = $name;
    %lot<decinc> = $decinc;

    make(Entry::Posting::Annot::Lot.new(|%lot));
}

method lot:disposition ($/ --> Nil)
{
    my %lot;

    my VarName:D $name = $<lot-name>.made;
    my DecInc:D $decinc = DEC;

    %lot<name> = $name;
    %lot<decinc> = $decinc;

    make(Entry::Posting::Annot::Lot.new(|%lot));
}

# --- --- end lot grammar-actions }}}

method annot($/ --> Nil)
{
    my %annot;

    my %xe = $<xe>.made if $<xe>;
    my %inherit = $<inherit>.made if $<inherit>;
    my Entry::Posting::Annot::Lot:D $lot = $<lot>.made if $<lot>;

    %annot<xe> = %xe if %xe;
    %annot<inherit> = %inherit if %inherit;
    %annot<lot> = $lot if $lot;

    make(%annot);
}

# --- end posting annotation grammar-actions }}}

method posting($/ --> Nil)
{
    my Str:D $text = ~$/;
    my XXHash:D $xxhash = xxHash32($text);

    my Entry::Posting::Account:D $account = $<account>.made;
    my Entry::Posting::Amount:D $amount = $<amount>.made;
    my Entry::Posting::Annot:D $annot =
        gen-annot($amount.asset-quantity, $<annot>.made) if $<annot>;

    my PlusMinus:D $plus-or-minus =
        $amount.plus-or-minus if $amount.plus-or-minus;
    my DecInc:D $decinc =
        $plus-or-minus.defined && $plus-or-minus eq '-' ?? DEC !! INC;

    my %make = :$account, :$amount, :$annot, :$decinc, :$text, :$xxhash;
    make(%make);
}

method posting-line($/ --> Nil)
{
    make($<posting>.made);
}

method postings($/ --> Nil)
{
    my @made = @<posting-line>.map({ .made }).grep(Hash:D);
    make(@made);
}

# end posting grammar-actions }}}
# entry grammar-actions {{{

method entry($/ --> Nil)
{
    my Str:D $text = ~$/;
    my Hash:D @postings = $<postings>.made;

    # Entry::ID
    my XXHash:D $xxhash = xxHash32($text);
    my Entry::ID:D $entry-id =
        Entry::ID.new(
            :number(@.entry-number.hyper.deepmap({ .clone })),
            :$xxhash,
            :$text
        );

    # insert Posting::ID derived from Entry::ID
    my UInt:D $posting-number = 0;
    my Entry::Posting:D @posting =
        @postings.hyper.map({
            my Entry::Posting::ID:D $posting-id =
                Entry::Posting::ID.new(
                    :$entry-id,
                    :number($posting-number++),
                    :xxhash($_<xxhash>),
                    :text($_<text>)
                );
            Entry::Posting.new(
                :account($_<account>),
                :amount($_<amount>),
                :annot($_<annot>),
                :decinc($_<decinc>),
                :id($posting-id)
            );
        });

    @!entry-number[*-1]++;

    make(Entry.new(:id($entry-id), :header($<header>.made), :@posting));
}

# end entry grammar-actions }}}
# include grammar-actions {{{

method filename($/ --> Nil)
{
    make($<var-name-string>.made);
}

method txnlib($/ --> Nil)
{
    make($<txnlib-string>.made);
}

method include:filename ($match --> Nil)
{
    # if relative path given, resolve path relative to current txn file
    # being parsed and append '.txn' extension
    # if absolute path given, use it directly
    my Str:D $filename =
        $match<filename>.made.IO.is-relative
            ?? join('/', $.file.IO.dirname, $match<filename>.made) ~ '.txn'
            !! $match<filename>.made;

    $filename.IO.e && $filename.IO.r && $filename.IO.f
        or die(X::TXN::Parser::Include.new(:$filename));

    my UInt:D @entry-number = |@.entry-number.hyper.deepmap({ .clone }), 0;
    my TXN::Parser::Actions:D $actions =
        TXN::Parser::Actions.new(
            :@entry-number,
            :$.date-local-offset,
            :file($filename),
            :$.include-lib
        );
    my Entry:D @entry =
        TXN::Parser::Grammar.parsefile($filename, :$actions).made;
    @!entry-number[*-1]++;
    $match.make(@entry);
}

method include:txnlib ($match --> Nil)
{
    $match<txnlib>.made.IO.is-relative
        or die(X::TXN::Parser::TXNLibAbsolute(:lib($match<txnlib>.made)));

    my Str:D $filename = join('/', $.include-lib, $match<txnlib>.made) ~ '.txn';
    $filename.IO.e && $filename.IO.r && $filename.IO.f
        or die(X::TXN::Parser::Include.new(:$filename));

    my UInt:D @entry-number = |@.entry-number.hyper.deepmap({ .clone }), 0;
    my TXN::Parser::Actions:D $actions =
        TXN::Parser::Actions.new(
            :@entry-number,
            :$.date-local-offset,
            :file($filename),
            :$.include-lib
        );
    my Entry:D @entry =
        TXN::Parser::Grammar.parsefile($filename, :$actions).made;
    @!entry-number[*-1]++;
    $match.make(@entry);
}

method include-line($/ --> Nil)
{
    make($<include>.made);
}

# end include grammar-actions }}}
# ledger grammar-actions {{{

method segment:entry ($/ --> Nil)
{
    make($<entry>.made);
}

method segment:include ($/ --> Nil)
{
    make($<include-line>.made);
}

method segment:blank ($/ --> Nil)
{
    make(Nil);
}

method segment:comment ($/ --> Nil)
{
    make(Nil);
}

method ledger($/ --> Nil)
{
    my Entry:D @entry =
        @<segment>
            .map({ .made })
            .map({ .grep(Entry:D) })
            .flat;
    make(@entry);
}

method TOP($/ --> Nil)
{
    make($<ledger>.made);
}

# end ledger grammar-actions }}}

# helper functions {{{

sub gen-annot(
    Quantity $asset-quantity,
    % (
        :%xe,
        :%inherit,
        Entry::Posting::Annot::Lot :$lot
    )
    --> Entry::Posting::Annot:D
)
{
    my %annot;

    my Entry::Posting::Annot::XE:D $xe =
        gen-xe($asset-quantity, :%xe) if %xe;
    my Entry::Posting::Annot::Inherit:D $inherit =
        gen-xe($asset-quantity, :%inherit) if %inherit;

    %annot<xe> = $xe if $xe;
    %annot<inherit> = $inherit if $inherit;
    %annot<lot> = $lot if $lot;

    my Entry::Posting::Annot:D $annot = Entry::Posting::Annot.new(|%annot);
}

multi sub gen-xe(
    Quantity:D $amount-asset-quantity,
    :xe(%)! (
        AssetCode:D :$asset-code!,
        Price:D :$asset-price!,
        XERateType:D :$rate-type!,
        Str :$asset-symbol
    )
    --> Entry::Posting::Annot::XE:D
)
{
    my %xe-rate;

    %xe-rate<asset-code> = $asset-code;
    %xe-rate<asset-price> =
        $rate-type ~~ IN-TOTAL
            ?? ($asset-price / $amount-asset-quantity)
            !! $asset-price;
    %xe-rate<asset-symbol> = $asset-symbol if $asset-symbol;

    my Entry::Posting::Annot::XE:D $xe =
        Entry::Posting::Annot::XE.new(|%xe-rate);
}

multi sub gen-xe(
    Quantity:D $amount-asset-quantity,
    :inherit(%)! (
        AssetCode:D :$asset-code!,
        Price:D :$asset-price!,
        XERateType:D :$rate-type!,
        Str :$asset-symbol
    )
    --> Entry::Posting::Annot::Inherit:D
)
{
    my %inherit-rate;

    %inherit-rate<asset-code> = $asset-code;
    %inherit-rate<asset-price> =
        $rate-type ~~ IN-TOTAL
            ?? ($asset-price / $amount-asset-quantity)
            !! $asset-price;
    %inherit-rate<asset-symbol> = $asset-symbol if $asset-symbol;

    my Entry::Posting::Annot::Inherit:D $inherit =
        Entry::Posting::Annot::Inherit.new(|%inherit-rate);
}

# end helper functions }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
