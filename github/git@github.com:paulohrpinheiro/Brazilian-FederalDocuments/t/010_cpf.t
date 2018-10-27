use v6.c;
use Test;

use lib 'lib';

use Brazilian::FederalDocuments;


plan 4;


my $cpf-do-temer = 6931987887;


ok FederalDocuments::CPF.new(number => $cpf-do-temer).is-valid, "Valid CPF as number";
ok FederalDocuments::CPF.new(number => "$cpf-do-temer").is-valid, "Valid CPF as string";

nok FederalDocuments::CPF.new(number => $cpf-do-temer + 1).is-valid, "Invalid CPF as number";
nok FederalDocuments::CPF.new(number => "{$cpf-do-temer}9").is-valid, "Invalid CPF as string";
