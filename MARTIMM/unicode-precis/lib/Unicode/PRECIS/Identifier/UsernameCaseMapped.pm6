use v6.c;
use Unicode::PRECIS;
use Unicode::PRECIS::Identifier;

#-------------------------------------------------------------------------------
# rfc7613 7.1.  UsernameCaseMapped Profile
#
#   IANA has added the following entry to the "PRECIS Profiles" registry.
#
#   Name:  UsernameCaseMapped.
#
#   Base Class:  IdentifierClass.
#
#   Applicability:  Usernames in security and application protocols.
#
#   Replaces:  The SASLprep profile of stringprep.
#
#   Width-Mapping Rule:  Map fullwidth and halfwidth characters to their
#   decomposition mappings.
#
#   Additional Mapping Rule:  None.
#
#   Case-Mapping Rule:  Map uppercase and titlecase characters to
#   lowercase.
#
#   Normalization Rule:  NFC.
#
#   Specification:  RFC 7613 (this document), Section 3.2.
#
#-------------------------------------------------------------------------------
unit package Unicode;

class PRECIS::Identifier::UsernameCaseMapped {
  also is Unicode::PRECIS::Identifier;

  #-----------------------------------------------------------------------------
  # rfc7613 3.2.1.  Preparation
  method prepare ( Str $s --> TestValue ) {

    my TestValue $tv = self.apply-rules( $s, ( WidthMap, CaseMap, Norm));
    return False if $tv ~~ Bool;

    # rfc7613 3.1.  Definition
    # Check that strings are not empty
    return False unless $tv.chars;

    return self.apply-tests($tv) ?? $tv !! False;
  }

  #-----------------------------------------------------------------------------
  # rfc7613 3.2.2.  Enforcement
  method enforce ( Str $s --> TestValue ) {

    my TestValue $tv = self.apply-rules( $s, ( WidthMap, CaseMap, Norm, Bidi));
    return False if $tv ~~ Bool;

    # rfc7613 3.1.  Definition
    # Check that strings are not empty
    return False unless $tv.chars;

    return self.apply-tests($tv) ?? $tv !! False;
  }

  #-----------------------------------------------------------------------------
  # rfc7613 3.2.3.  Comparison
  method compare ( Str $s1, Str $s2 --> Bool ) {

    my TestValue $tv1 = self.enforce($s1);
    return False if $tv1 ~~ Bool;

    my TestValue $tv2 = self.enforce($s2);
    return False if $tv2 ~~ Bool;

    # Perl6 compares in NFC form where (pre)composed characters are forced
    return $tv1 eq $tv2;
  }
}
