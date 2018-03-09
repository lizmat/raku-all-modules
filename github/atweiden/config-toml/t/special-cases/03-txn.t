use v6;
use lib 'lib';
use Test;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;

plan(2);

subtest({
    my Str $toml = slurp('t/data/sample.txn.toml');
    my Config::TOML::Parser::Actions $actions .= new;
    my $match-toml = Config::TOML::Parser::Grammar.parse($toml, :$actions);

    is(
        $match-toml.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 1 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML document successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Header><date>,
        Date.new('2014-01-01'),
        q:to/EOF/
        ♪ [Is expected value?] - 2 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Header><date>
        ┃   Success   ┃        ~~ Date.new('2014-01-01')
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Header><description>,
        'I started the year with $1000 in Bankwest cheque account',
        q:to/EOF/
        ♪ [Is expected value?] - 3 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Header><description>
        ┃   Success   ┃        ~~ '...'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Header><importance>,
        0,
        q:to/EOF/
        ♪ [Is expected value?] - 4 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Header><importance>
        ┃   Success   ┃        == 0
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Header><tags>,
        [ 'TAG1', 'TAG2' ],
        q:to/EOF/
        ♪ [Is expected value?] - 5 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Header><tags>
        ┃   Success   ┃        ~~ [ 'TAG1', 'TAG2' ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[0]<Account><silo>,
        'ASSETS',
        q:to/EOF/
        ♪ [Is expected value?] - 6 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[0]<Account><silo>
        ┃   Success   ┃        ~~ 'ASSETS'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[0]<Account><entity>,
        'Personal',
        q:to/EOF/
        ♪ [Is expected value?] - 7 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[0]<Account><entity>
        ┃   Success   ┃        ~~ 'Personal'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[0]<Account><subaccount>,
        [ 'Bankwest', 'Cheque' ],
        q:to/EOF/
        ♪ [Is expected value?] - 8 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[0]<Account><subaccount>
        ┃   Success   ┃        ~~ [ 'Bankwest', 'Cheque' ]
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[0]<Amount><asset-code>,
        'USD',
        q:to/EOF/
        ♪ [Is expected value?] - 9 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[0]<Amount><asset-code>
        ┃   Success   ┃        ~~ 'USD'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[0]<Amount><asset-quantity>,
        1000.00,
        q:to/EOF/
        ♪ [Is expected value?] - 10 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[0]<Amount><asset-quantity>
        ┃   Success   ┃        == 1000.00
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[0]<Amount><asset-symbol>,
        '$',
        q:to/EOF/
        ♪ [Is expected value?] - 11 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[0]<Amount><asset-symbol>
        ┃   Success   ┃        ~~ '$'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[0]<Amount><plus-or-minus>,
        '',
        q:to/EOF/
        ♪ [Is expected value?] - 12 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[0]<Amount><plus-or-minus>
        ┃   Success   ┃        ~~ ''
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[1]<Account><silo>,
        'EQUITY',
        q:to/EOF/
        ♪ [Is expected value?] - 13 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[1]<Account><silo>
        ┃   Success   ┃        ~~ 'EQUITY'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[1]<Account><entity>,
        'Personal',
        q:to/EOF/
        ♪ [Is expected value?] - 14 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[1]<Account><entity>
        ┃   Success   ┃        ~~ 'Personal'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[1]<Account><subaccount>,
        [],
        q:to/EOF/
        ♪ [Is expected value?] - 15 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[1]<Account><subaccount>
        ┃   Success   ┃        ~~ []
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[1]<Amount><asset-code>,
        'USD',
        q:to/EOF/
        ♪ [Is expected value?] - 16 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[1]<Amount><asset-code>
        ┃   Success   ┃        ~~ 'USD'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[1]<Amount><asset-quantity>,
        1000.00,
        q:to/EOF/
        ♪ [Is expected value?] - 17 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[1]<Amount><asset-quantity>
        ┃   Success   ┃        == 1000.00
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[1]<Amount><asset-symbol>,
        '$',
        q:to/EOF/
        ♪ [Is expected value?] - 18 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[1]<Amount><asset-symbol>
        ┃   Success   ┃        ~~ '$'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<Entry>[0]<Posting>[1]<Amount><plus-or-minus>,
        '',
        q:to/EOF/
        ♪ [Is expected value?] - 19 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<Entry>[0]<Posting>[1]<Amount><plus-or-minus>
        ┃   Success   ┃        ~~ ''
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

subtest({
    my Str $toml = slurp('t/data/txnjrnl.toml');
    my Config::TOML::Parser::Actions $actions .= new;
    my $match-toml = Config::TOML::Parser::Grammar.parse($toml, :$actions);

    is(
        $match-toml.WHAT,
        Config::TOML::Parser::Grammar,
        q:to/EOF/
        ♪ [Grammar.parse($toml, :$actions)] - 20 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Parses TOML document successfully
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<drift>,
        0,
        q:to/EOF/
        ♪ [Is expected value?] - 21 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<drift> == 0
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<entity>,
        'VarName',
        q:to/EOF/
        ♪ [Is expected value?] - 22 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<entity> ~~ 'VarName'
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<EntryID><number>,
        0,
        q:to/EOF/
        ♪ [Is expected value?] - 22 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<EntryID><number> == 0
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<EntryID><xxhash>,
        5555555,
        q:to/EOF/
        ♪ [Is expected value?] - 23 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<EntryID><xxhash>
        ┃   Success   ┃        == 5555555
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<EntryID><text>,
        'capture entry',
        q:to/EOF/
        ♪ [Is expected value?] - 24 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<EntryID><text>
        ┃   Success   ┃        ~~ 'capture entry'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModHoldings><AssetCode><entity>,
        'VarName',
        q:to/EOF/
        ♪ [Is expected value?] - 25 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModHoldings><AssetCode><entity>
        ┃   Success   ┃        ~~ 'VarName'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModHoldings><AssetCode><asset-code>,
        'AssetCode',
        q:to/EOF/
        ♪ [Is expected value?] - 26 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModHoldings><AssetCode><asset-code>
        ┃   Success   ┃        ~~ 'AssetCode'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModHoldings><AssetCode><asset-flow>,
        'AssetFlow',
        q:to/EOF/
        ♪ [Is expected value?] - 27 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModHoldings><AssetCode><asset-flow>
        ┃   Success   ┃        ~~ 'AssetFlow'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModHoldings><AssetCode><costing>,
        'Costing',
        q:to/EOF/
        ♪ [Is expected value?] - 28 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModHoldings><AssetCode><costing>
        ┃   Success   ┃        ~~ 'Costing'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModHoldings><AssetCode><date>,
        'DateTime',
        q:to/EOF/
        ♪ [Is expected value?] - 29 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModHoldings><AssetCode><date>
        ┃   Success   ┃        ~~ 'DateTime'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModHoldings><AssetCode><price>,
        5.55,
        q:to/EOF/
        ♪ [Is expected value?] - 30 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModHoldings><AssetCode><price>
        ┃   Success   ┃        == 5.55
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModHoldings><AssetCode><acquisition-price-asset-code>,
        'AssetCode',
        q:to/EOF/
        ♪ [Is expected value?] - 31 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModHoldings><AssetCode><acquisition-price-asset-code>
        ┃   Success   ┃        ~~ 'AssetCode'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModHoldings><AssetCode><quantity>,
        5.5555555,
        q:to/EOF/
        ♪ [Is expected value?] - 32 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModHoldings><AssetCode><quantity>
        ┃   Success   ┃        == 5.5555555
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<silo>,
        'SILO',
        q:to/EOF/
        ♪ [Is expected value?] - 33 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<silo>
        ┃   Success   ┃        ~~ 'SILO'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<entity>,
        'VarName',
        q:to/EOF/
        ♪ [Is expected value?] - 34 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<entity>
        ┃   Success   ┃        ~~ 'VarName'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<subwallet>[0],
        'VarName',
        q:to/EOF/
        ♪ [Is expected value?] - 35 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<subwallet>[0]
        ┃   Success   ┃        ~~ 'VarName'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<asset-code>,
        'AssetCode',
        q:to/EOF/
        ♪ [Is expected value?] - 36 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<asset-code>
        ┃   Success   ┃        ~~ 'AssetCode'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<decinc>,
        'DecInc',
        q:to/EOF/
        ♪ [Is expected value?] - 37 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<decinc>
        ┃   Success   ┃        ~~ 'DecInc'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<quantity>,
        5.5555555,
        q:to/EOF/
        ♪ [Is expected value?] - 38 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<quantity>
        ┃   Success   ┃        == 5.5555555
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<xe-asset-code>,
        '',
        q:to/EOF/
        ♪ [Is expected value?] - 39 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<xe-asset-code>
        ┃   Success   ┃        ~~ ''
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<xe-asset-quantity>,
        '',
        q:to/EOF/
        ♪ [Is expected value?] - 40 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<xe-asset-quantity>
        ┃   Success   ┃        ~~ ''
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<EntryID><number>,
        0,
        q:to/EOF/
        ♪ [Is expected value?] - 41 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<EntryID><number>
        ┃   Success   ┃        == 0
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<EntryID><xxhash>,
        5555555,
        q:to/EOF/
        ♪ [Is expected value?] - 42 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<EntryID><xxhash>
        ┃   Success   ┃        == 5555555
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<EntryID><text>,
        'capture entry',
        q:to/EOF/
        ♪ [Is expected value?] - 43 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<EntryID><text>
        ┃   Success   ┃        ~~ 'capture entry'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<PostingID><number>,
        0,
        q:to/EOF/
        ♪ [Is expected value?] - 44 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<PostingID><number>
        ┃   Success   ┃        == 0
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<PostingID><xxhash>,
        55555557,
        q:to/EOF/
        ♪ [Is expected value?] - 45 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<PostingID><xxhash>
        ┃   Success   ┃        == 55555557
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<PostingID><text>,
        'capture posting',
        q:to/EOF/
        ♪ [Is expected value?] - 46 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<PostingID><text>
        ┃   Success   ┃        ~~ 'capture posting'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<PostingID><EntryID><number>,
        0,
        q:to/EOF/
        ♪ [Is expected value?] - 47 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<PostingID><EntryID><number>
        ┃   Success   ┃        == 0
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<PostingID><EntryID><xxhash>,
        5555555,
        q:to/EOF/
        ♪ [Is expected value?] - 48 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<PostingID><EntryID><xxhash>
        ┃   Success   ┃        == 5555555
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    is(
        $match-toml.made<TXN>[0]<ModWallet>[0]<PostingID><EntryID><text>,
        'capture entry',
        q:to/EOF/
        ♪ [Is expected value?] - 49 of 49
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ $match-toml.made<TXN>[0]<ModWallet>[0]<PostingID><EntryID><text>
        ┃   Success   ┃        ~~ 'capture entry'
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
