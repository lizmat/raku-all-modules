use v6;

class DB::Migration::Simple {
    has $.verbose = False;
    has $.dbh is required;
    has $.migration-file is required;
    has $.migration-table-name = 'db-migrations-simple-meta';
    has %!cfg = self!read-config();

    method current-version() {
        try {
            my $sth = $!dbh.prepare(qq:to/END-STATEMENT/);
                SELECT value FROM '$!migration-table-name'
                    WHERE key = 'current-version'
            END-STATEMENT
            $sth.execute();
            my @rows = $sth.allrows();
            $sth.finish();
            self!debug("current-version: allrows: "~@rows.gist);
            return @rows[0][0];
        }
        if $! {
            self!init-meta-table();
        }
        return 0;
    }

    method migrate(:$version is copy = 'latest') {
        my Int $current-version = self.current-version();

        self!debug(%!cfg);

        $version = %!cfg.keys.max(*.Int) if $version eq 'latest';
        my Int $target-version = $version.Int;
        self!debug("migrating from version '$current-version' to version '$target-version'");
        if $current-version == $target-version {
            self!debug("DB already at version $version");
            return $version;
        }
        my $direction = ($current-version < $target-version) ?? 'up' !! 'down';

        self!debug("$!verbose migrating '$direction' from version '$current-version' to version '$target-version'");

        $!dbh.do('BEGIN TRANSACTION');

        my @versions = $direction eq 'up'
            ?? ($current-version + 1 ... $target-version)
            !! ($current-version ... $target-version + 1);

        for @versions -> $version {
            self!debug("doing '$direction' migrations for $version");

            next without %!cfg{$version}{$direction};

            # At the moment, I don't see how DBIish can execute
            # multiple statements at once. Doing a transaction manually
            # is hopefully fine. Please point out if that is wrong.
            for %!cfg{$version}{$direction}.split(/[\;\s*]+$$/) -> $stmt {
                # Splitting at ; leaves us with the last $stmt empty
                # Also, it makes us happily accept double semicolons: "CREATE.. ;; INSERT.. ;
                next if $stmt ~~ /^\s*$/;
                self!debug("executing $stmt");
                try $!dbh.do($stmt);
                if $! {
                    $!dbh.do('ROLLBACK');
                    self!debug("error: $!");
                    fail $!;
                }
            }
        }
        $!dbh.do(qq:to/END-STATEMENT/);
            UPDATE '$!migration-table-name'
                SET value = '$target-version'
                WHERE key = 'current-version'
        END-STATEMENT
        $!dbh.do('COMMIT');
        return $target-version;
    }

    method !read-config() {
        my %cfg;
        for $!migration-file.IO.slurp().split(/\n/) -> $line is copy {
            state ($version, $direction);

            # get rid of comments and empty lines
            next if $line ~~ /^\s*$/;
            next if $line ~~ /^\s*\#/;

            self!debug("line: $line");

            # everything after a line starting with "--" belongs together
            if $line ~~ /^'--' \s* (\d+) \s* (up|down)/ {
                $version = $0;
                $direction = $1;
                self!debug("version: $version, direction: $direction");
            }
            else {
                # We merge the lines and split SQL statements on the semicolons.
                # This allows for multi line statements which make our migrations
                # file more readable. E.g long CREATE TABLE statements.
                %cfg{$version}{$direction} ~= $line ~"\n";
            }
        }
        return %cfg;
    }

    method !debug($msg) {
        note $msg if $!verbose;
    }

    method !init-meta-table() {
        self!debug("initializing $!migration-table-name");
        $!dbh.do(qq:to/END-STATEMENT/);
            CREATE TABLE IF NOT EXISTS '$!migration-table-name' (
                key     TEXT UNIQUE NOT NULL,
                value   INTEGER NOT NULL CHECK (value >= 0)
            )
        END-STATEMENT

        $!dbh.do(qq:to/END-STATEMENT/);
            INSERT INTO '$!migration-table-name'
                VALUES ('current-version', 0)
        END-STATEMENT
        self!debug("set initial version to 0");
    }
}
