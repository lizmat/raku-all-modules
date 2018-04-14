use v6.c;

use DBIx::NamedQueries;

class Queries::Write::Test does DBIx::NamedQueries::Write {

    method alter ( %params ) { }

    method create ( %params ) {
        return {
            statement => qq~
                CREATE TABLE users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name varchar(4) UNIQUE,
                    description varchar(30),
                    quantity int,
                    price numeric(5,2)
                );
            ~
        };
    }

    method insert ( %params ) {
        return {
            fields => [ 'name', 'description', 'quantity', 'price', ],
            statement => qq~INSERT INTO users (name, description, quantity, price)
                  VALUES ( ?, ?, ?, ? )~
        };
    }

    method update ( %params ) { }
}
