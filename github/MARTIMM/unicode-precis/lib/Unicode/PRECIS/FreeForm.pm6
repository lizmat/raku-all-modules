use v6.c;
use Unicode::PRECIS;

#-------------------------------------------------------------------------------
# Texts are also taken directly from rfc7564
#-------------------------------------------------------------------------------
# FreeformClass:  a sequence of letters, numbers, symbols, spaces, and other
#    characters that is used for free-form strings, including passwords as well
#    as display elements such as human-friendly nicknames for devices or for
#    participants in a chatroom; the intent is that this class will allow nearly
#    any Unicode character, with the result that expressiveness has been
#    prioritized over safety for this class.  Note well that protocol designers,
#    application developers, service providers, and end users might not
#    understand or be able to enter all of the characters that can be included
#    in the FreeformClass -- see Section 12.3 for details.
unit package Unicode;

class PRECIS::FreeForm is Unicode::PRECIS {

  #-----------------------------------------------------------------------------
  method calculate-value ( Int $codepoint --> PropValue ) {

    if $codepoint (elem) $Unicode::PRECIS::exceptions {
      self.exceptions($codepoint);
    }

    elsif $codepoint (elem) $Unicode::PRECIS::backwardcompatible {
      self.backwardcompatible($codepoint);
    }

    elsif self.unassigned($codepoint) { UNASSIGNED; }
    elsif self.ascii7($codepoint) { PVALID; }
    elsif self.join-control($codepoint) { CONTEXTJ; }
    elsif self.old-hangul-jamo($codepoint) { DISALLOWED; }
    elsif self.precis-ignorable-properties($codepoint) { DISALLOWED; }
    elsif self.control($codepoint) { DISALLOWED; }
    elsif self.has-compat($codepoint) { FREE-PVAL; }
    elsif self.letter-digits($codepoint) { PVALID; }
    elsif self.other-letter-digits($codepoint) { FREE-PVAL; }
    elsif self.space($codepoint) { FREE-PVAL; }
    elsif self.symbol($codepoint) { FREE-PVAL; }
    elsif self.punctuation($codepoint) { FREE-PVAL; }
    else { DISALLOWED; }
  }

  #-----------------------------------------------------------------------------
  # rfc7613 4.1.  Definition
  method prop-accept ( PropValue $result --> Bool ) {

    # Not ok if any of the list is found
    $result !~~ any(<CONTEXTJ CONTEXTO DISALLOWED ID-DIS UNASSIGNED>);
  }
}
