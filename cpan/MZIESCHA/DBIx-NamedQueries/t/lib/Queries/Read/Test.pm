use v6.c;

use DBIx::NamedQueries;

class Queries::Read::Test does DBIx::NamedQueries::Read {

    method select( %params ) { 
        return {
            statement => q@
                SELECT
                    *
                FROM
                    users
                WHERE 1
            @,
        };
    }

    method list( %params ) {
        return {
            fields => [
                {
                    name => 'description'
                },
            ],
            statement => q@
                SELECT
                    *
                FROM
                    users
                WHERE 1
            @ ~ ( %params<description>:exists ?? q@AND description = ?@ !! q@@ )
            ,
        };
    }
    method find( %params ) {  }
}
