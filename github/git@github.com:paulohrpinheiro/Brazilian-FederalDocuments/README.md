# Brazilian::FederalDocuments

[![Build Status](https://travis-ci.org/paulohrpinheiro/Brazilian-FederalDocuments.svg)](https://travis-ci.org/paulohrpinheiro/Brazilian-FederalDocuments)
[![GitPitch](https://gitpitch.com/assets/badge.svg)](https://gitpitch.com/paulohrpinheiro/Brazilian-FederalDocuments/master?grs=github&t=white)

## Synopsis

    use Brazilian::FederalDocuments;

    if FederalDocuments::CPF(number => 6931987887).is-valid {
        say "Valid CPF!!!"
    } else {
        say "Invalid CPF..."
    }

    if FederalDocuments::CNPJ(number => 394411000109).is-valid {
        say "Valid CNPF!!!"
    } else {
        say "Invalid CNPF..."
    }

## Description

In Brazil, there are two numbers of documents used especially for financial
transactions. For individuals, the CPF (Individual Persons Registry), and for
companies, the CNPJ (National Registry of Legal Entities).

This module verifies that the numbers are valid.

## COPYRIGHT

This library is free software; you can redistribute it and/or modify it under
the terms of the [MIT License](https://en.wikipedia.org/wiki/MIT_License).
