use v6;
use lib 'lib';
use Test;
use TXN::Parser::Grammar;

plan 7;

# posting account grammar tests {{{

subtest
{
    my Str @accounts =
        Q{assets.personal.co-ro-na.coolers},
        Q{AsSeTs:Business:Cats},
        Q{ASSETS:Arnelies:Barbells},
        Q{expenses.Personal.Travel.Airfare.Alaska},
        Q{ExpEnSeS:qr9:Entertainment:Concerts:TearsForFears},
        Q{EXPENSES.Work.Software."Micro$oft".Wind0ze},
        Q{income:i:extravaganza},
        Q{IncOmE."∅"},
        Q{INCOME."First Bank Co.".Salary},
        Q{liabilities.me.wrecking_yard},
        Q{LiabILItiES:Irene:LoansPayable:LionelHutz},
        Q{LIABILITIES.Gschlauf.CreditCard},
        Q{equity:personal},
        Q{EqUItY:"Moon Crow"},
        Q{EQUITY.Business};

    sub is-valid-account(Str:D $account) returns Bool:D
    {
        TXN::Parser::Grammar.parse($account, :rule<account>).so;
    }

    ok(
        @accounts.grep({is-valid-account($_)}).elems == @accounts.elems,
        q:to/EOF/
        ♪ [Grammar.parse($account, :rule<account>)] - 1 of 9
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Account names validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end posting account grammar tests }}}
# posting amount grammar tests {{{

# --- plus or minus {{{

subtest
{
    my Str @plus-or-minus = Q{+}, Q{-};

    sub is-valid-plus-or-minus(Str:D $plus-or-minus) returns Bool:D
    {
        TXN::Parser::Grammar.parse(
            $plus-or-minus,
            :rule<plus-or-minus>
        ).so;
    }

    ok(
        @plus-or-minus.grep({is-valid-plus-or-minus($_)}).elems ==
            @plus-or-minus.elems,
        q:to/EOF/
        ♪ [Grammar.parse($plus-or-minus, :rule<plus-or-minus>)] - 2 of 9
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Plus / Minus signs validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# --- end plus or minus }}}
# --- asset code and symbol {{{

subtest
{
    # asset code and symbol, indexed by name
    my List %asset-code-symbol{Str} =
        bitcoin                        => Qw{BTC ฿},
        litecoin                       => Qw{LTC Ł},
        us-dollar                      => Qw{USD $},
        euro                           => Qw{EUR €},
        british-pound                  => Qw{GBP £},
        indian-rupee                   => Qw{INR ₹},
        australian-dollar              => Qw{AUD $},
        canadian-dollar                => Qw{CAD $},
        singapore-dollar               => Qw{SGD $},
        swiss-franc                    => Qw{CHF CHF},
        malaysian-ringgit              => Qw{MYR RM},
        japanese-yen                   => Qw{JPY ¥},
        chinese-yuan-renminbi          => Qw{CNY ¥},
        new-zealand-dollar             => Qw{NZD $},
        thai-baht                      => Qw{THB ฿},
        hungarian-forint               => Qw{HUF Ft},
        emirati-dirham                 => Qw{AED د.إ},
        hong-kong-dollar               => Qw{HKD HK$},
        mexican-peso                   => Qw{MXN $},
        south-african-rand             => Qw{ZAR R},
        philippine-peso                => Qw{PHP ₱},
        swedish-krona                  => Qw{SEK kr},
        indonesian-rupiah              => Qw{IDR Rp},
        saudi-arabian-riyal            => Qw{SAR ﷼},
        brazilian-real                 => Qw{BRL R$},
        turkish-lira                   => Qw{TRY TRY},
        kenyan-shilling                => Qw{KES KSh},
        south-korean-won               => Qw{KRW ₩},
        egyptian-pound                 => Qw{EGP £},
        iraqi-dinar                    => Qw{IQD د.ع},
        norwegian-krone                => Qw{NOK kr},
        kuwaiti-dinar                  => Qw{KWD ك},
        russian-ruble                  => Qw{RUB руб},
        danish-krone                   => Qw{DKK kr},
        pakistani-rupee                => Qw{PKR ₨},
        israeli-shekel                 => Qw{ILS ₪},
        polish-zloty                   => Qw{PLN zł},
        qatari-riyal                   => Qw{QAR ﷼},
        gold-ounce                     => Qw{XAU XAU},
        omani-rial                     => Qw{OMR ﷼},
        colombian-peso                 => Qw{COP $},
        chilean-peso                   => Qw{CLP $},
        taiwan-new-dollar              => Qw{TWD NT$},
        argentine-peso                 => Qw{ARS $},
        czech-koruna                   => Qw{CZK Kč},
        vietnamese-dong                => Qw{VND ₫},
        moroccan-dirham                => Qw{MAD MAD},
        jordanian-dinar                => Qw{JOD JOD},
        bahraini-dinar                 => Qw{BHD BD},
        cfa-franc                      => Qw{XOF XOF},
        sri-lankan-rupee               => Qw{LKR ₨},
        ukrainian-hryvnia              => Qw{UAH ₴},
        nigerian-naira                 => Qw{NGN ₦},
        tunisian-dinar                 => Qw{TND TND},
        ugandan-shilling               => Qw{UGX UGX},
        romanian-new-leu               => Qw{RON lei},
        bangladeshi-taka               => Qw{BDT Tk},
        peruvian-nuevo-sol             => Qw{PEN S/.},
        georgian-lari                  => Qw{GEL GEL},
        central-african-cfa-franc-beac => Qw{XAF XAF},
        fijian-dollar                  => Qw{FJD $},
        venezuelan-bolivar             => Qw{VEF Bs.},
        belarusian-ruble               => Qw{BYR p.},
        croatian-kuna                  => Qw{HRK kn},
        uzbekistani-som                => Qw{UZS лв},
        bulgarian-lev                  => Qw{BGN лв},
        algerian-dinar                 => Qw{DZD DZD},
        iranian-rial                   => Qw{IRR ﷼},
        dominican-peso                 => Qw{DOP RD$},
        icelandic-krona                => Qw{ISK kr},
        silver-ounce                   => Qw{XAG XAG},
        costa-rican-colon              => Qw{CRC ₡};

    my Str @quoted-asset-codes =
        Q{"Honda S2000 VIN JHLRE4H73AC092103"},
        Q{"The House at 178 Blue Kodiak Trail"},
        Q{"Widget:Bobblehead #88"};

    sub is-valid-asset-code(Str:D $asset-code) returns Bool:D
    {
        TXN::Parser::Grammar.parse($asset-code, :rule<asset-code>).so;
    }

    sub is-valid-asset-symbol(Str:D $asset-symbol) returns Bool:D
    {
        TXN::Parser::Grammar.parse(
            $asset-symbol,
            :rule<asset-symbol>
        ).so;
    }

    ok(
        %asset-code-symbol.grep({is-valid-asset-code(.values[0][0])}).elems ==
            %asset-code-symbol.elems,
        q:to/EOF/
        ♪ [Grammar.parse($asset-code, :rule<asset-code>)] - 3 of 9
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Asset codes validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    ok(
        %asset-code-symbol.grep({is-valid-asset-symbol(.values[0][1])}).elems ==
            %asset-code-symbol.elems,
        q:to/EOF/
        ♪ [Grammar.parse($asset-symbol, :rule<asset-symbol>)] - 4 of 9
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Asset symbols validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    ok(
        @quoted-asset-codes.grep({is-valid-asset-code($_)}).elems ==
            @quoted-asset-codes.elems,
        q:to/EOF/
        ♪ [Grammar.parse($asset-code, :rule<asset-code>)] - 5 of 9
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Quoted asset codes validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# --- end asset code and symbol }}}
# --- asset quantity {{{

subtest
{
    my Str @asset-quantities =
        Q{10000},
        Q{10_000},
        Q{10_000.00},
        Q{9_8_7_6_5.4_3_2_1_0};

    sub is-valid-asset-quantity(Str:D $asset-quantity) returns Bool:D
    {
        TXN::Parser::Grammar.parse(
            $asset-quantity,
            :rule<asset-quantity>
        ).so;
    }

    ok(
        @asset-quantities.grep({is-valid-asset-quantity($_)}).elems ==
            @asset-quantities.elems,
        q:to/EOF/
        ♪ [Grammar.parse($asset-quantity, :rule<asset-quantity>)] - 6 of 9
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Asset quantities validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# --- end asset quantity }}}
# --- exchange rate {{{

subtest
{
    my Str @exchange-rates =
        Q{@ 10_000 USD},
        Q{@ USD 10_000},
        Q{@ $10_000.99 USD},
        Q{@ USD $10_000.99},
        Q{@ 50 BRL},
        Q{@ BRL 50},
        Q{@ R$50.99 BRL},
        Q{@ BRL R$50.99},
        Q{@ 1_000 VEF},
        Q{@ VEF 1_000},
        Q{@ Bs.1_000.99 VEF},
        Q{@ VEF Bs.1_000.99},
        Q{@ 50 BTC},
        Q{@ BTC 50},
        Q{@ ฿50.99 BTC},
        Q{@ BTC ฿50.99},
        Q{@ 1_000_000 TRY},
        Q{@ TRY 1_000_000},
        Q{@ TRY1_000_000.99 TRY},
        Q{@ TRY TRY1_000_000.99},
        Q{@ 50 KWD},
        Q{@ KWD 50},
        Q{@ ك50.99 KWD},
        Q{@ KWD ك50.99},
        Q{@ 1_000 DKK},
        Q{@ DKK 1_000},
        Q{@ kr1_000 DKK},
        Q{@ DKK kr1_000},
        Q{@ 5000 RUB},
        Q{@ RUB 5000},
        Q{@ руб5000.99 RUB},
        Q{@ RUB руб5000.99},
        Q{@ 100_000 JPY},
        Q{@ JPY 100_000},
        Q{@ ¥100_000.99 JPY},
        Q{@ JPY ¥100_000.99},
        Q{@ 500 PKR},
        Q{@ PKR 500},
        Q{@ ₨500.99 PKR},
        Q{@ PKR ₨500.99},
        Q{@ 1_000 PEN},
        Q{@ PEN 1_000},
        Q{@ S/.1_000.99 PEN},
        Q{@ PEN S/.1_000.99},
        Q{@ 5000 IQD},
        Q{@ IQD 5000},
        Q{@ د.ع5000.99 IQD},
        Q{@ IQD د.ع5000.99};

    sub is-valid-exchange-rate(Str:D $exchange-rate) returns Bool:D
    {
        TXN::Parser::Grammar.parse($exchange-rate, :rule<xe>).so;
    }

    ok(
        @exchange-rates.grep({is-valid-exchange-rate($_)}).elems ==
            @exchange-rates.elems,
        q:to/EOF/
        ♪ [Grammar.parse($exchange-rate, :rule<xe>)] - 7 of 9
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Exchange rates validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# --- end exchange rate }}}
# --- amount {{{

subtest
{
    my Str @amounts =
        Q{100 BTC},
        Q{1_0_0 BTC},
        Q{-100 BTC},
        Q{-1_0_0 BTC},
        Q{+100 BTC},
        Q{+1_0_0 BTC},
        Q{100.00 BTC},
        Q{1_0_0.0_0 BTC},
        Q{-100.00 BTC},
        Q{-1_0_0.0_0 BTC},
        Q{+100.00 BTC},
        Q{+1_0_0.0_0 BTC},
        Q{฿100.00 BTC},
        Q{฿1_0_0.0_0 BTC},
        Q{-฿100.00 BTC},
        Q{-฿1_0_0.0_0 BTC},
        Q{+฿100.00 BTC},
        Q{+฿1_0_0.0_0 BTC},
        Q{BTC 100},
        Q{BTC 1_0_0},
        Q{BTC -100},
        Q{BTC -1_0_0},
        Q{BTC +100},
        Q{BTC +1_0_0},
        Q{BTC 100.00},
        Q{BTC 1_0_0.0_0},
        Q{BTC -100.00},
        Q{BTC -1_0_0.0_0},
        Q{BTC +100.00},
        Q{BTC +1_0_0.0_0},
        Q{BTC ฿100.00},
        Q{BTC ฿1_0_0.0_0},
        Q{BTC -฿100.00},
        Q{BTC -฿1_0_0.0_0},
        Q{BTC +฿100.00},
        Q{BTC +฿1_0_0.0_0};

    sub is-valid-amount(Str:D $amount) returns Bool:D
    {
        TXN::Parser::Grammar.parse($amount, :rule<amount>).so;
    }

    ok(
        @amounts.grep({is-valid-amount($_)}).elems == @amounts.elems,
        q:to/EOF/
        ♪ [Grammar.parse($amount, :rule<amount>)] - 8 of 9
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Amounts validate successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# --- end amount }}}

# end posting amount grammar tests }}}
# posting grammar tests {{{

subtest
{
    my Str @postings =
        Q{Assets:Personal:Coinbase    -฿100.00 BTC @ $5000.00 USD},
        Q{Assets:Personal:FirstBank +฿1_000_000.00 USD},
        Q{Expenses:Business:Cats:Food      Ł5.99 LTC};

    sub is-valid-posting(Str:D $posting) returns Bool:D
    {
        TXN::Parser::Grammar.parse($posting, :rule<posting>).so;
    }

    ok(
        @postings.grep({is-valid-posting($_)}).elems == @postings.elems,
        q:to/EOF/
        ♪ [Grammar.parse($amount, :rule<amount>)] - 9 of 9
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Amounts validate successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
}

# end posting grammar tests }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
