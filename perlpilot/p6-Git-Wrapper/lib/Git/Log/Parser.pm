class Git::Wrapper::Log {
    has $.sha1;
    has $.author;
    has $.email;
    has $.date;
    has $.message;

    method summary() {
        return self.message.split("\n").[0];
    }
}

grammar Git::Log::Parser {
    token TOP {
        ^ <commit>+  % [$$ \n] $
    }

    token commit {
        ^^ 'commit' <.ws> <sha1> $$ \n
        ^^ 'Author:' <.ws> <author> <?before <.ws> > '<' ~ '>' <email> $$ \n
        ^^ 'Date:' <.ws> <date> $$ \n
        ^^ $$ \n
        ^^ <message>
    }

    token sha1 { <[ A..Z a..z 0..9 ]>+ }

    token author { <-[ \< ] >+ }

    token email { <-[ \> ] >+ }
    
    token date { \N+ }

    token message { <indented-line>+ }

    token indented-line { <.space> ** 4 \N+ $$ \n }
}

class Git::Log::Actions {
    method TOP($/) { 
        make [ $<commit>».made ];
    }
    method commit($/) { 
        my $isodate = ~$<date>;
        $isodate.=subst(' ', 'T', :n(1)).=subst(' ', '');
        make Git::Wrapper::Log.new(
            sha1 => ~$<sha1>, author => ~$<author>.trim, email => ~$<email>,
            date => DateTime.new($isodate), message => $<message>.made,
        )
    }
    method message($/) {
        make join "\n", @($<indented-line>)».trim;
    }
}
