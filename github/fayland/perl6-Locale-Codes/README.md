# perl6-Locale-Codes

[![Build Status](https://travis-ci.org/fayland/perl6-Locale-Codes.svg?branch=master)](https://travis-ci.org/fayland/perl6-Locale-Codes)

## SYNOPSIS

```
use Locale::Country;

my $country = code2country('JP'); # 'Japan'
my $code = country2code('Norway'); # 'NO'
my @codes = all_country_codes();
my @names = all_country_names();

use Locale::Currency;

my $currency = code2currency('usd'); # 'US Dollar'
my $code = currency2code('Euro'); # 'EUR'
my @codes = all_currency_codes();
my @names = all_currency_names();

use Locale::Language;

my $language = code2language('EN'); # 'English'
my $code = language2code('French'); # 'FR'
my @codes = all_language_codes();
my @names = all_language_names();
```

## Locale::Country

supports

 * alpha-2, LOCALE_CODE_ALPHA_2
 * alpha-3, LOCALE_CODE_ALPHA_3
 * numeric, LOCALE_CODE_NUMERIC

### code2country

```
my $country = code2country('JP'); # 'Japan'
my $country = code2country('CHN'); # 'China'
my $country = code2country('250'); # 'France'
```

### country2code

```
my $code = country2code('Norway'); # 'NO', default alpha-2
my $code = country2code('Norway', LOCALE_CODE_ALPHA_2), 'NO';
my $code = country2code('Norway', 'numeric'); # '578'
```

### all_country_codes

```
my @codes = all_country_codes(); # alpha-2
my @codes = all_country_codes('alpha-3');
my @codes = all_country_codes(LOCALE_CODE_NUMERIC);
```

### all_country_names

```
my @names = all_country_names();
```

## Locale::Currency

supports

 * alpha, LOCALE_CURR_ALPHA
 * num, LOCALE_CURR_NUMERIC

### code2currency

```
my $currency = code2currency('usd'); # 'US Dollar'
```

### currency2code

```
my $code = currency2code('Euro'); # 'EUR'
my $code = currency2code('Euro', 'num'); # '978'
```

### all_currency_codes

```
my @codes = all_currency_codes(); # alpha
my @codes = all_currency_codes(LOCALE_CURR_NUMERIC);
```

### all_currency_names

```
my @names = all_currency_names();
```

## Locale::Language

supports

 * alpha-2, LOCALE_LANG_ALPHA_2
 * alpha-3, LOCALE_LANG_ALPHA_3
 * term, LOCALE_LANG_TERM

### code2language

```
my $language = code2language('EN'); # 'English'
my $language = code2language('ENG', 'term'); # 'English'
```

### language2code

```
my $code = language2code('French'); # 'FR'
my $code = language2code('French', LOCALE_LANG_ALPHA_3); # 'FRE'
```

### all_language_codes

```
my @codes = all_language_codes(); # alpha
my @codes = all_language_codes(LOCALE_LANG_ALPHA_3);
```

### all_language_names

```
my @names = all_language_names();
```

## Locale::Script

supports

 * alpha, LOCALE_SCRIPT_ALPHA
 * num, LOCALE_SCRIPT_NUMERIC

### code2script

```
my $script = code2script('phnx'); # 'Phoenician'
```

### script2code

```
my $code = script2code('Phoenician'); # 'Phnx'
my $code = script2code('Phoenician', 'num'); # '115'
```

### all_script_codes

```
my @codes = all_script_codes(); # alpha
my @codes = all_script_codes(LOCALE_SCRIPT_NUMERIC);
```

### all_script_names

```
my @names = all_script_names();
```