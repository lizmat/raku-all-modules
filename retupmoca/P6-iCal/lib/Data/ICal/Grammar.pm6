grammar Data::ICal::Grammar {
    regex section {
        'BEGIN:' <name> \n
        [
        | <section>
        | <property>
        ]*
        'END:' $<name> \n?
    }

    regex property {
        <name> <meta>* ':' <value>
    }

    token name {
        \w+
    }

    token meta {
        ';' <name> '=' <mvalue>
    }

    token mvalue {
        <-[:;]>+
    }

    regex value {
        <firstline>
        <extralines>*
    }

    token firstline {
        \N+ \n
    }

    token extralines {
        \s \N+ \n
    }
}

class Data::ICal::Actions {
    method section($/) {
        my %ret;
        %ret<name> = ~$<name>;

        for @$<section> {
            %ret<sections>.push: $_.made;
        }

        for @$<property> {
            %ret<properties>.push: $_.made;
        }

        $/.make: %ret;
    }

    method property($/) {
        my %ret;
        %ret<name> = ~$<name>;

        %ret<value> = $<value>.made;

        for @$<meta> {
            my $m = $_.made;
            %ret<meta>{$m<name>} = $m<value>;
        }

        $/.make: %ret;
    }

    method value($/) {
        my $str = ~$<firstline>;
        $str .= subst(/\n$/, '');

        for @$<extralines> -> $l is copy {
            $l = ~$l;
            $l .= subst(/^\s/, '');
            $l .= subst(/\n$/, '');
            $str ~= $l;
        }

        $str .= subst(/\\n/, "\n", :g);

        $/.make: $str;
    }

    method meta($/) {
        my %ret;
        %ret<name> = ~$<name>;
        %ret<value> = ~$<mvalue>;

        $/.make: %ret;
    }
}
