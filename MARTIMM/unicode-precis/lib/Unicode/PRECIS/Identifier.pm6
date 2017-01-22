use v6.c;
use Unicode::PRECIS;

#-------------------------------------------------------------------------------
# Texts are also taken directly from rfc7564
#-------------------------------------------------------------------------------
# IdentifierClass:  a sequence of letters, numbers, and some symbols that is
#    used to identify or address a network entity such as a user account, a
#    venue (e.g., a chatroom), an information source (e.g., a data feed), or a
#    collection of data (e.g., a file); the intent is that this class will
#    minimize user confusion in a wide variety of application protocols, with
#    the result that safety has been prioritized over expressiveness for this
#    class.
unit package Unicode;

class PRECIS::Identifier is Unicode::PRECIS {

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
    elsif self.has-compat($codepoint) { ID-DIS; }
    elsif self.letter-digits($codepoint) { PVALID; }
    elsif self.other-letter-digits($codepoint) { ID-DIS; }
    elsif self.space($codepoint) { ID-DIS; }
    elsif self.symbol($codepoint) { ID-DIS; }
    elsif self.punctuation($codepoint) { ID-DIS; }
    else { DISALLOWED; }
  }

  #-----------------------------------------------------------------------------
  # rfc7613 3.1.  Definition
  method prop-accept ( PropValue $result --> Bool ) {

    # Not ok if any of the list is found
    $result !~~ any(<CONTEXTJ CONTEXTO DISALLOWED ID-DIS UNASSIGNED>);
  }
}
