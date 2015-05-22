use Git::PurePerl::Object;
unit class Git::PurePerl::Object::Commit is Git::PurePerl::Object;
use Git::PurePerl::Actor;
use DateTime::TimeZone;

has $.kind = 'commit';
has Str $.tree_sha1 is rw;
has Str @.parent_sha1s is rw = Array[Str].new;
has Git::PurePerl::Actor $.author is rw;
has DateTime $.authored_time is rw;
has Git::PurePerl::Actor $.committer is rw;
has DateTime $.committed_time is rw;
has Str $.comment is rw;
has Str $.encoding is rw;

my %method_map = (
    'tree'      => 'tree_sha1',
    'parent'    => '_push_parent_sha1',
    'author'    => 'authored_time',
    'committer' => 'committed_time'
);

submethod BUILD {
    return unless self.content;
    my @lines = split "\n", self.content;
    my %header;
    while ( my $line = shift @lines ) {
        last unless $line;
        my ( $key, $value ) = split ' ', $line, 2;
        push %header{$key}, $value;
    }
    %header<encoding> = 'utf-8';
        # ||= [ self.git.config.get(key => "i18n.commitEncoding") || "utf-8" ];
    my $encoding = %header<encoding>[*-1];
    for keys %header -> $key is copy {
        for %header{$key}.list -> $value is copy {
            $value = $value.encode('latin-1').decode($encoding);
            if ( $key eq 'committer' or $key eq 'author' ) {
                my @data = split ' ', $value;
                my ( $email, $epoch, $tz ) = splice( @data, *-3 );
                $email = substr( $email, 1, *-1 );
                my $name = join ' ', @data;
                my $actor
                    = Git::PurePerl::Actor.new( :$name, :$email );
                self."$key"() = $actor;
                $key = %method_map{$key};
                my $dt
                    = DateTime.new( +$epoch, :timezone(tz-offset $tz) );
                self."$key"() = $dt;
            } else {
                $key = %method_map{$key} || $key;
                self."$key"() = $value;
            }
        }
    }
    $!comment = join("\n", @lines).encode('latin-1').decode($encoding);
}


method tree {
    return self.git.get_object( self.tree_sha1 );
}


method _push_parent_sha1 () is rw {
    Proxy.new:
        FETCH => { True },
        STORE => -> $, $sha1 { push(@!parent_sha1s, $sha1) };
}

method parent_sha1 {
    return @.parent_sha1s[0];
}
  
method parent {
    return self.git.get_object( self.parent_sha1 );
}

method parents {
    return map { self.git.get_object( $_ ) }, self.parent_sha1s;
}

# vim: ft=perl6
