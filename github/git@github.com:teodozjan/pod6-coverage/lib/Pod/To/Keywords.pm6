use v6;
use Pod::To::Text;
use Pod::Coverage::Result;


# Strips I<keywords> that indicate documented methods/classes/subs etc.
class Pod::To::Keywords {
    has Pod::Coverage::Result $.results = ();
    
    method render(@pod) {
        for @pod -> $pode {
            for $pode.contents -> $v {

                if $v ~~ Pod::Block::Named {
                    say $v.name.lc ~ ' ' ~ $v.contents[0].contents ;

                }
                
                if $v ~~ Pod::Heading  {
                    Pod::To::Text.render( $v.contents) ;
                }

                # TODO check header METHODS
                if $v ~~ Pod::Item {
                    say "routine " ~ Pod::To::Text.render( $v.contents );
                }
            }
            
            
        }

    }
}

=begin pod

=TITLE Pod::To::Keywords

=SYNOPSIS perl6 --doc=Keywords

=begin DESCRIPTION

This pod parser tries to extract module documentation information
basing on semantic keywords

=end DESCRIPTION

=METHOD render

Render description

=end pod

