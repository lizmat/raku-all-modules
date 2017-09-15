use v6.c;
use Test;

use lib 'lib';

use Brazilian::FederalDocuments;


plan 4;


my $cnpj-da-presidencia = 394411000109;


ok FederalDocuments::CNPJ.new(number => $cnpj-da-presidencia).is-valid, "Valid CNPJ as number";
ok FederalDocuments::CNPJ.new(number => "$cnpj-da-presidencia").is-valid, "Valid CNPJ as string";

nok FederalDocuments::CNPJ.new(number => $cnpj-da-presidencia + 1).is-valid, "Invalid CNPJ as number";
nok FederalDocuments::CNPJ.new(number => "{$cnpj-da-presidencia}9").is-valid, "Invalid CNPJ as string";
