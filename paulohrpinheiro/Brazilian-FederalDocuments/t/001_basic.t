use v6.c;
use Test;

use lib 'lib';

use Brazilian::FederalDocuments;


plan 2;


ok FederalDocuments::CPF  ~~ FederalDocuments::Document;
ok FederalDocuments::CNPJ ~~ FederalDocuments::Document;
