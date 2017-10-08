use v6;

class LibYAML::Loader::TestSuite {
    has Str @.events;

    method stream-start-event(Hash $event, $parser) {
        my $ev = "+STR";
        @.events.push: $ev;
    }

    method stream-end-event(Hash $event, $parser) {
        my $ev = "-STR";
        @.events.push: $ev;
    }

    method document-start-event(Hash $event, $parser) {
        my $ev = "+DOC";
        my $implicit = $event<implicit>;
        if (not $implicit) {
            $ev ~= " ---";
        }
        @.events.push: $ev;
    }

    method document-end-event(Hash $event, $parser) {
        my $ev = "-DOC";
        my $implicit = $event<implicit>;
        if (not $implicit) {
            $ev ~= " ...";
        }
        @.events.push: $ev;
    }

    method mapping-start-event(Hash $event, $parser) {
        my $ev = "+MAP";
        my $anchor = $event<anchor>;
        my $tag = $event<tag>;
        if (defined $anchor) {
            $ev ~= " &$anchor";
        }
        if (defined $tag) {
            $ev ~= " <$tag>";
        }
        @.events.push: $ev;
    }

    method mapping-end-event(Hash $event, $parser) {
        my $ev = "-MAP";
        @.events.push: $ev;
    }

    method sequence-start-event(Hash $event, $parser) {
        my $ev = "+SEQ";
        my $anchor = $event<anchor>;
        my $tag = $event<tag>;
        if (defined $anchor) {
            $ev ~= " &$anchor";
        }
        if (defined $tag) {
            $ev ~= " <$tag>";
        }
        @.events.push: $ev;
    }

    method sequence-end-event(Hash $event, $parser) {
        my $ev = "-SEQ";
        @.events.push: $ev;
    }

    my %scalar-styles = (
        plain => ':',
        single => "'",
        double => '"',
        literal => '|',
        folded => '>',
    );
    method scalar-event(Hash $event, $parser) {
        my $ev = "=VAL";
        my $value = $event<value>;
        my $anchor = $event<anchor>;
        my $tag = $event<tag>;
        my $style = $event<style>;

        $value ~~ s:g/\\/\\\\/;
        $value ~~ s:g/\n/\\n/;
        $value ~~ s:g/\t/\\t/;
        my $tstyle = %scalar-styles{ $style };
        if (defined $anchor) {
            $ev ~= " &$anchor";
        }
        if (defined $tag) {
            $ev ~= " <$tag>";
        }
        $ev ~= " " ~ $tstyle ~ $value;
        @.events.push: $ev;
    }

    method alias-event(Hash $event, $parser) {
        my $ev = "=ALI";
        my $alias = $event<alias>;
        $ev ~= " *$alias";
        @.events.push: $ev;
    }

}
