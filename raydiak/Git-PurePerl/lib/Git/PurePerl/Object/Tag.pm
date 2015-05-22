use Git::PurePerl::Object;
unit class Git::PurePerl::Object::Tag is Git::PurePerl::Object;
use Git::PurePerl::Actor;
use DateTime::TimeZone;

has $.kind = 'tag';
has Str $.object is rw;
has Str $.tag is rw;
has Git::PurePerl::Actor $.tagger is rw;
has DateTime $.tagged_time is rw;
has Str $.comment is rw;
has $.object_kind is rw;

my %method_map = type => 'object_kind';

submethod BUILD {
    my @lines = split "\n", self.content;
    while ( my $line = shift @lines ) {
        last unless $line;
        my ( $key, $value ) = split ' ', $line, 2;
        
        if ($key eq 'tagger') {
        	my @data = split ' ', $value;
        	my ($email, $epoch, $tz) = splice(@data, *-3);
        	my $name = join(' ', @data);
        	my $actor = 
        		Git::PurePerl::Actor.new( :$name, :$email );
        	$!tagger = $actor;
            my $dt= DateTime.new( +$epoch, :timezone(tz-offset $tz) );
	        $!tagged_time = $dt;
	    } else {
			my $method = %method_map{$key} || $key;
	        self."$method"() = $value;
	    }
    }
    $!comment = join "\n", @lines;
}

# vim: ft=perl6
