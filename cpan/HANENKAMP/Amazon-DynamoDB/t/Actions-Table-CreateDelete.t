#!/usr/bin/env perl6
use v6;

use Test;
use Amazon::DynamoDB;

use lib 't/lib';
use Test::Amazon::DynamoDB;

unless test-env-is-ok() {
    plan :skip-all(test-env-skip-message);
}

plan 4;

my $ddb = new-dynamodb-actions();

lives-ok {
    my $res = await $ddb.CreateTable(|test-data('Thread-create'));

    CATCH {
        when X::Amazon::DynamoDB::CommunicationError {
            note .request.Str;
            note .response.decoded-content;

            #.rethrow;
        }
    }

    is $res<TableDescription><TableName>, tn('Thread');
}

lives-ok {
    my $res = await $ddb.DeleteTable(TableName => tn('Thread'));

    is $res<TableDescription><TableName>, tn('Thread');
}

done-testing;
