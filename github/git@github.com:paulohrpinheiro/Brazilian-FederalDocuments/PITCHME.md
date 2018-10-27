# Criando um módulo em Perl6 sem saber Perl6

![Camelia »ö«](camelia.png)

São Paulo, 16/SET/2017 - GuruSP @ TOTVS

---

## Sobre mim

Paulo Henrique Rodrigues Pinheiro (paulohrpinheiro):

* https://about.me/paulohrpinheiro
* https://paulohrpinheiro.xyz
* https://www.twitter.com/paulohrpinheiro
* https://linkedin.com/in/paulohrpinheiro
* https://github.com/paulohrpinheiro

---

### A cara do Perl6

    ➜  ~ perl6
    > my @primes = grep { .is-prime }, ^∞
    [...]
    > @primes[^10]
    (2 3 5 7 11 13 17 19 23 29)
    > my @p = 1,2,4,8...Inf
    [...]
    > @p[4..10]
    (16 32 64 128 256 512 1024)
    > (½ +1)²
    2.25

---

## Fazer o quê?

> Fuçar no Perl6, sem muita paciência.

Construir um módulo simples, e publicá-lo:

Brazilian::FederalDocuments

https://github.com/paulohrpinheiro/Brazilian-FederalDocuments

---

## Mão na massa

    ➜ tree
    .
    ├── lib
    │   └── Brazilian
    │       └── FederalDocuments.pm6
    ├── LICENSE
    ├── META6.json
    └── t
        ├── 001_basic.t
        ├── 010_cpf.t
        └── 020_cnpj.t

---

### t/010_cpf.t

    use v6.c;
    use Test;

    use lib 'lib';
    use Brazilian::FederalDocuments;

    plan 2;

    my $cpf-do-temer = 6931987887;

    ok  True,  "descrição";
    nok False, "outra descrição";

---

### Testando

    ➜  prove -e perl6 t 
    t/001_basic.t .. ok   
    t/010_cpf.t .... ok   
    t/020_cnpj.t ... ok   
    All tests successful.
    Files=3, Tests=10,  2 wallclock secs ( 0.03 usr  0.01 sys +  2.34 cusr  0.22 csys =  2.60 CPU)
    Result: PASS

---

### lib/Brazilian/FederalDocuments.pm6

    use v6.c;

    unit module FederalDocuments;

    role Document {
        has $.number;
        has Bool $!valid = False;
        has @!weight-masc-first-digit;
        has @!weight-masc-second-digit;
        has @!digits;

        method is-valid() {
            $!valid
        }

---

### O Core do módulo

    @!digits = (
        ("0" x ($total-len - $.number.chars)) ~ $.number
    ).split(/\d/, :v, :skip-empty);

    my $first-digit  = sum(
        @!digits Z* @!weight-masc-first-digit
    )  * 10 % 11;

---

## Links úteis

* https://perl6.org
* http://rakudo.org/
* https://github.com/tadzik/rakudobrew
* https://modules.perl6.org/
* http://greenteapress.com/wp/think-perl-6/
* http://perl6intro.com/
* https://learnxinyminutes.com/docs/perl6/

__OBRIGADO!!!__
