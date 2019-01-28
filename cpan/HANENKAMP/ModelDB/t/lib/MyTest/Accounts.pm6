use v6;

unit package MyTest::Accounts;

use ModelDB;

module Model {
    use ModelDB::ModelBuilder;

    subset Side of Str
        where 'Left' | 'Right';

    constant Left = 'Left';
    constant Right = 'Right';

    model Account {
        has Int $.id is column is primary;
        has Str $.name is column;
        has Side $.account-type is column;
        has Int $.balance is column;

        method balance-amount(--> Rat) {
            $.balance / 100 * $.type-sign
        }

        method is-left(--> Bool) {
            $.account-type eq Left
        }

        method is-right(--> Bool) {
            $.account-type eq Right
        }

        method type-sign(--> Int) {
            $.is-left ?? -1 !! 1
        }
    }

    model GeneralLedger {
        has Int $.id is column is primary;
        has Int $.line is column;
    }

    model LedgerLine {
        has Int $.id is column is primary;
        has Int $.ledger-id is column;
        has Int $.account-id is column;
        has Str $.reference-number is column;
        has Str $.description is column;
        has Str $.memo is column;
        has Int $.pennies is column;

        method is-saved(--> Bool) { $.id.defined }
        method is-left(--> Bool) { $.pennies < 0 }
        method is-right(--> Bool) { $.pennies > 0 }

        method left-amount(--> Rat) { $.left ?? -$.amount !! 0 }
        method right-amount(--> Rat) { $.right ?? $.amount !! 0 }
        method account-amount(--> Rat) { $.amount * $.type-sign }
        method amount(--> Rat) { $.pennies / 100 }
        method abs-amount(--> Rat) { abs($.amount) }

    }
}

class Schema is ModelDB::Schema {
    use ModelDB::SchemaBuilder;

    has ModelDB::Table[Model::Account] $.accounts is table;
    has ModelDB::Table[Model::GeneralLedger] $.lines is table;
    has ModelDB::Table[Model::LedgerLine] $.entries is table;
}
