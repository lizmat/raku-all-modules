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

    sub is_valid_account(Str:D $account) returns Bool:D
    {
        TXN::Parser::Grammar.parse($account, :rule<account>).so;
    }

    ok(
        @accounts.grep({is_valid_account($_)}).elems == @accounts.elems,
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
    my Str @plus_or_minus = Q{+}, Q{-};

    sub is_valid_plus_or_minus(Str:D $plus_or_minus) returns Bool:D
    {
        TXN::Parser::Grammar.parse(
            $plus_or_minus,
            :rule<plus_or_minus>
        ).so;
    }

    ok(
        @plus_or_minus.grep({is_valid_plus_or_minus($_)}).elems ==
            @plus_or_minus.elems,
        q:to/EOF/
        ♪ [Grammar.parse($plus_or_minus, :rule<plus_or_minus>)] - 2 of 9
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
    my List %asset_code_symbol{Str} =
        bitcoin                        => Qw{BTC ฿},
        litecoin                       => Qw{LTC Ł},
        us_dollar                      => Qw{USD $},
        euro                           => Qw{EUR €},
        british_pound                  => Qw{GBP £},
        indian_rupee                   => Qw{INR ₹},
        australian_dollar              => Qw{AUD $},
        canadian_dollar                => Qw{CAD $},
        singapore_dollar               => Qw{SGD $},
        swiss_franc                    => Qw{CHF CHF},
        malaysian_ringgit              => Qw{MYR RM},
        japanese_yen                   => Qw{JPY ¥},
        chinese_yuan_renminbi          => Qw{CNY ¥},
        new_zealand_dollar             => Qw{NZD $},
        thai_baht                      => Qw{THB ฿},
        hungarian_forint               => Qw{HUF Ft},
        emirati_dirham                 => Qw{AED د.إ},
        hong_kong_dollar               => Qw{HKD HK$},
        mexican_peso                   => Qw{MXN $},
        south_african_rand             => Qw{ZAR R},
        philippine_peso                => Qw{PHP ₱},
        swedish_krona                  => Qw{SEK kr},
        indonesian_rupiah              => Qw{IDR Rp},
        saudi_arabian_riyal            => Qw{SAR ﷼},
        brazilian_real                 => Qw{BRL R$},
        turkish_lira                   => Qw{TRY TRY},
        kenyan_shilling                => Qw{KES KSh},
        south_korean_won               => Qw{KRW ₩},
        egyptian_pound                 => Qw{EGP £},
        iraqi_dinar                    => Qw{IQD د.ع},
        norwegian_krone                => Qw{NOK kr},
        kuwaiti_dinar                  => Qw{KWD ك},
        russian_ruble                  => Qw{RUB руб},
        danish_krone                   => Qw{DKK kr},
        pakistani_rupee                => Qw{PKR ₨},
        israeli_shekel                 => Qw{ILS ₪},
        polish_zloty                   => Qw{PLN zł},
        qatari_riyal                   => Qw{QAR ﷼},
        gold_ounce                     => Qw{XAU XAU},
        omani_rial                     => Qw{OMR ﷼},
        colombian_peso                 => Qw{COP $},
        chilean_peso                   => Qw{CLP $},
        taiwan_new_dollar              => Qw{TWD NT$},
        argentine_peso                 => Qw{ARS $},
        czech_koruna                   => Qw{CZK Kč},
        vietnamese_dong                => Qw{VND ₫},
        moroccan_dirham                => Qw{MAD MAD},
        jordanian_dinar                => Qw{JOD JOD},
        bahraini_dinar                 => Qw{BHD BD},
        cfa_franc                      => Qw{XOF XOF},
        sri_lankan_rupee               => Qw{LKR ₨},
        ukrainian_hryvnia              => Qw{UAH ₴},
        nigerian_naira                 => Qw{NGN ₦},
        tunisian_dinar                 => Qw{TND TND},
        ugandan_shilling               => Qw{UGX UGX},
        romanian_new_leu               => Qw{RON lei},
        bangladeshi_taka               => Qw{BDT Tk},
        peruvian_nuevo_sol             => Qw{PEN S/.},
        georgian_lari                  => Qw{GEL GEL},
        central_african_cfa_franc_beac => Qw{XAF XAF},
        fijian_dollar                  => Qw{FJD $},
        venezuelan_bolivar             => Qw{VEF Bs.},
        belarusian_ruble               => Qw{BYR p.},
        croatian_kuna                  => Qw{HRK kn},
        uzbekistani_som                => Qw{UZS лв},
        bulgarian_lev                  => Qw{BGN лв},
        algerian_dinar                 => Qw{DZD DZD},
        iranian_rial                   => Qw{IRR ﷼},
        dominican_peso                 => Qw{DOP RD$},
        icelandic_krona                => Qw{ISK kr},
        silver_ounce                   => Qw{XAG XAG},
        costa_rican_colon              => Qw{CRC ₡};

    my Str @quoted_asset_codes =
        Q{"Honda S2000 VIN JHLRE4H73AC092103"},
        Q{"The House at 178 Blue Kodiak Trail"},
        Q{"Widget:Bobblehead #88"};

    sub is_valid_asset_code(Str:D $asset_code) returns Bool:D
    {
        TXN::Parser::Grammar.parse($asset_code, :rule<asset_code>).so;
    }

    sub is_valid_asset_symbol(Str:D $asset_symbol) returns Bool:D
    {
        TXN::Parser::Grammar.parse(
            $asset_symbol,
            :rule<asset_symbol>
        ).so;
    }

    ok(
        %asset_code_symbol.grep({is_valid_asset_code(.values[0][0])}).elems ==
            %asset_code_symbol.elems,
        q:to/EOF/
        ♪ [Grammar.parse($asset_code, :rule<asset_code>)] - 3 of 9
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Asset codes validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    ok(
        %asset_code_symbol.grep({is_valid_asset_symbol(.values[0][1])}).elems ==
            %asset_code_symbol.elems,
        q:to/EOF/
        ♪ [Grammar.parse($asset_symbol, :rule<asset_symbol>)] - 4 of 9
        ┏━━━━━━━━━━━━━┓
        ┃             ┃  ∙ Asset symbols validate successfully, as
        ┃   Success   ┃    expected.
        ┃             ┃
        ┗━━━━━━━━━━━━━┛
        EOF
    );

    ok(
        @quoted_asset_codes.grep({is_valid_asset_code($_)}).elems ==
            @quoted_asset_codes.elems,
        q:to/EOF/
        ♪ [Grammar.parse($asset_code, :rule<asset_code>)] - 5 of 9
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
    my Str @asset_quantities =
        Q{10000},
        Q{10_000},
        Q{10_000.00},
        Q{9_8_7_6_5.4_3_2_1_0};

    sub is_valid_asset_quantity(Str:D $asset_quantity) returns Bool:D
    {
        TXN::Parser::Grammar.parse(
            $asset_quantity,
            :rule<asset_quantity>
        ).so;
    }

    ok(
        @asset_quantities.grep({is_valid_asset_quantity($_)}).elems ==
            @asset_quantities.elems,
        q:to/EOF/
        ♪ [Grammar.parse($asset_quantity, :rule<asset_quantity>)] - 6 of 9
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
    my Str @exchange_rates =
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

    sub is_valid_exchange_rate(Str:D $exchange_rate) returns Bool:D
    {
        TXN::Parser::Grammar.parse(
            $exchange_rate,
            :rule<exchange_rate>
        ).so;
    }

    ok(
        @exchange_rates.grep({is_valid_exchange_rate($_)}).elems ==
            @exchange_rates.elems,
        q:to/EOF/
        ♪ [Grammar.parse($exchange_rate, :rule<exchange_rate>)] - 7 of 9
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

    sub is_valid_amount(Str:D $amount) returns Bool:D
    {
        TXN::Parser::Grammar.parse($amount, :rule<amount>).so;
    }

    ok(
        @amounts.grep({is_valid_amount($_)}).elems == @amounts.elems,
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

    sub is_valid_posting(Str:D $posting) returns Bool:D
    {
        TXN::Parser::Grammar.parse($posting, :rule<posting>).so;
    }

    ok(
        @postings.grep({is_valid_posting($_)}).elems == @postings.elems,
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

# vim: ft=perl6 fdm=marker fdl=0
