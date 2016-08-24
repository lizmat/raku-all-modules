use IRC::Client;
use DBIish;
use DBDish::SQLite::Connection;

unit class IRC::Client::Plugin::Factoid does IRC::Client::Plugin;

has Regex  $.trigger;
has Bool   $.say-not-found = True;
has Str    $.db-filename   = 'factoids.db';
has DBDish::SQLite::Connection $!dbh;

method irc-started {
    my $need-deploy = not $!db-filename.IO.e;
    $!dbh = DBIish.connect: "SQLite", :database($!db-filename), :RaiseError;
    return unless $need-deploy;

    $!dbh.do: q:to/END-SQL/;
        CREATE TABLE factoids (
            id   INTEGER PRIMARY KEY,
            fact TEXT,
            def  TEXT
        );
    END-SQL
}

method irc-to-me ($e) { self.handle: $e.text; }

method irc-privmsg-channel ($e) {
    return $.NEXT unless $!trigger;

    my $text = $e.text;
    return $.NEXT unless $text.subst-mutate: $!trigger, '';
    self.handle: $text;
}

method handle ($what is copy) {
    return $.NEXT
        if $!trigger and not $what.subst-mutate: $!trigger, '';

    return do given $what {
        when /^ '^purge' \s+ $<fact>=(.+) \s*/ {
            self!purge-fact: $<fact>;
        }
        when /^ '^delete' \s+ $<fact>=(.+) \s*/ {
            self!delete-fact: $<fact>;
        }
        when /$<fact>=(.+) \s+ ':is:' \s+ $<def>=(.+)/ {
            self!add-fact: $<fact>, $<def>;
        }
        default {
            my $def = self!find-facts($_, :1limit).first<def>;
            $def ?? $def !! $!say-not-found
                ?? 'nothing found' !! $.NEXT;
        }
    }
}

method !add-fact (Str() $fact, Str() $def) {
    $!dbh.do: 'INSERT INTO factoids (fact, def) VALUES (?,?)', $fact, $def;
    return "Added $fact as $def";
}

method !delete-fact (Str() $fact) {
    return "Didn't find $fact in the database"
        unless self!find-facts: $fact, :1limit;

    self!add-fact: $fact, '';
    return "Marked factoid `$fact` as deleted";
}

method !find-facts (Str() $fact, Int :$limit) {
    my $sth;
    my $sql = 'SELECT * FROM factoids WHERE fact = ? ORDER BY id DESC';
    if $limit {
        $sth = $!dbh.prepare: $sql ~ ' LIMIT ?';
        $sth.execute: $fact, $limit;
    }
    else {
        $sth = $!dbh.prepare: $sql;
        $sth.execute: $fact;
    }
    return $sth.fetchall-AoH;
}

method !purge-fact (Str() $fact) {
    my @facts = self!find-facts: $fact
        or return "Did not find $fact in the database";

    my @ids = @facts.map: *<id>;
    $!dbh.do:
        "DELETE FROM factoids WHERE id IN({ join ',', '?' xx @ids})", @ids;
    return "Purged factoid `$fact` and its {@facts.elems} edits";
}
