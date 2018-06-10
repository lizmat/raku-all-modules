use v6;
use lib 'lib';
use TXN::Parser::Grammar;
use lib 't/lib';
use TXNParserTest;
use Test;

plan(8);

# posting account grammar tests {{{

subtest({
    my Str @account =
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

    ok(
        @account.grep({ .&is-valid-account }).elems == @account.elems,
        q:to/EOF/
        ♪ [Grammar.parse($account, :rule<account>)] - 1 of 10
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Account names validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end posting account grammar tests }}}
# posting amount grammar tests {{{

# --- plus or minus {{{

subtest({
    my Str @plus-or-minus = Q{+}, Q{-};

    ok(
        @plus-or-minus
            .grep({ .&is-valid-plus-or-minus })
            .elems == @plus-or-minus.elems,
        q:to/EOF/
        ♪ [Grammar.parse($plus-or-minus, :rule<plus-or-minus>)] - 2 of 10
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Plus / Minus signs validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# --- end plus or minus }}}
# --- asset code and symbol {{{

subtest({
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

    my Str @quoted-asset-code =
        Q{"Honda S2000 VIN JHLRE4H73AC092103"},
        Q{"The House at 178 Blue Kodiak Trail"},
        Q{"Widget:Bobblehead #88"};

    ok(
        %asset-code-symbol
            .grep({ is-valid-asset-code(.values.first.first) })
            .elems == %asset-code-symbol.elems,
        q:to/EOF/
        ♪ [Grammar.parse($asset-code, :rule<asset-code>)] - 3 of 10
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Asset codes validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    ok(
        %asset-code-symbol
            .grep({ is-valid-asset-symbol(.values.first.tail) })
            .elems == %asset-code-symbol.elems,
        q:to/EOF/
        ♪ [Grammar.parse($asset-symbol, :rule<asset-symbol>)] - 4 of 10
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Asset symbols validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
    ok(
        @quoted-asset-code
            .grep({ .&is-valid-asset-code })
            .elems == @quoted-asset-code.elems,
        q:to/EOF/
        ♪ [Grammar.parse($asset-code, :rule<asset-code>)] - 5 of 10
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Quoted asset codes validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# --- end asset code and symbol }}}
# --- asset quantity {{{

subtest({
    my Str @asset-quantity =
        Q{10000},
        Q{10_000},
        Q{10_000.00},
        Q{9_8_7_6_5.4_3_2_1_0};

    ok(
        @asset-quantity
            .grep({ .&is-valid-asset-quantity })
            .elems == @asset-quantity.elems,
        q:to/EOF/
        ♪ [Grammar.parse($asset-quantity, :rule<asset-quantity>)] - 6 of 10
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Asset quantities validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# --- end asset quantity }}}
# --- unit of measure {{{

subtest({
    my Str @unit-of-measure =
        Q{cup},
        Q{c},
        Q{floz};

    ok(
        @unit-of-measure
            .grep({ .&is-valid-unit-of-measure })
            .elems == @unit-of-measure.elems,
        q:to/EOF/
        ♪ [Grammar.parse($unit-of-measure, :rule<unit-of-measure>)] - 7 of 10
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Units of measure validate successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# --- end unit of measure }}}
# --- exchange rate {{{

subtest({
    my Str @exchange-rate =
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

    ok(
        @exchange-rate
            .grep({ .&is-valid-exchange-rate })
            .elems == @exchange-rate.elems,
        q:to/EOF/
        ♪ [Grammar.parse($exchange-rate, :rule<xe>)] - 8 of 10
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Exchange rates validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# --- end exchange rate }}}
# --- amount {{{

subtest({
    my Str @amount =
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
        Q{BTC +฿1_0_0.0_0},
        Q{1 floz·sprite},
        Q{1.5 floz·sprite},
        Q{15_000.0 floz·sprite},
        Q{1 floz · sprite},
        Q{1 floz of sprite};

    ok(
        @amount.grep({ .&is-valid-amount }).elems == @amount.elems,
        q:to/EOF/
        ♪ [Grammar.parse($amount, :rule<amount>)] - 9 of 10
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Amounts validate successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# --- end amount }}}

# end posting amount grammar tests }}}
# posting grammar tests {{{

subtest({
    my Str @posting =
        Q{Assets:Personal:Coinbase    -฿100.00 BTC @ $5000.00 USD},
        Q{Assets:Personal:FirstBank +฿1_000_000.00 USD},
        Q{Expenses:Business:Cats:Food      Ł5.99 LTC},
        Q{Liabilities:Xray      1 floz·sprite},
        Q{Equity:Yankee 1.06 floz of sprite @ 0.05 USD},
        Q{Assets:Zero -42 oz·Au};

    ok(
        @posting.grep({ .&is-valid-posting }).elems == @posting.elems,
        q:to/EOF/
        ♪ [Grammar.parse($amount, :rule<amount>)] - 10 of 10
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Amounts validate successfully, as expected.
        ┃   Success   ┃
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );
});

# end posting grammar tests }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
