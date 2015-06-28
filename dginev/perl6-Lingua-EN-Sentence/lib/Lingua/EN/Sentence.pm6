unit module Lingua::EN::Sentence:auth<LlamaRider>;
use v6;

my Str $EOS="\0\0\0";
my token termpunct { <[.?!]> }
my token AP { [<['"»)\]}]>]? } ## AFTER PUNCTUATION
my token PAP { <termpunct> <AP> };
my token alphad { <.alpha>|'-' }

my @PEOPLE = <jr mr mrs ms dr prof sr sen sens rep reps gov atty attys
 supt det rev>;
my @ARMY = <col gen lt cmdr adm capt sgt cpl maj>;
my @INSTITUTES = <dept univ assn bros>;
my @COMPANIES = <inc ltd co corp>;
my @PLACES = <arc al ave blv blvd cl ct cres dr exp expy dist mt ft fwy fy
 hwy hway la pd pde pl plz rd st tce Ala Ariz Ark Cal Calif Col Colo Conn
 Del Fed Fla Ga Ida Id Ill Ind Ia Kan Kans Ken Ky La Md Is Mass 
 Mich Minn Miss Mo Mont Neb Nebr Nev Mex Okla Ok Ore Penna Penn Pa
 Dak Tenn Tex Ut Vt Va Wash Wis Wisc Wy Wyo USAFA Alta Man Ont Qué
 Sask Yuk>; # Me conflicts with me
my @MATH = <fig eq sec i'.'e e'.'g P'-'a'.'s cf Thm Def Conj resp>;
my @MONTHS = <jan feb mar apr may jun jul aug sep oct nov dec sept>;
my @MISC = <vs no esp>; # etc causes more problems than it solves

my Str @ABBREVIATIONS = (@PEOPLE, @ARMY, @INSTITUTES, @COMPANIES, @PLACES, @MONTHS, @MATH, @MISC ).map({.lc}).sort;
my $acronym_regexp = array_to_regexp(@ABBREVIATIONS);

sub add_acronyms(*@new_acronyms) is export {
  push @ABBREVIATIONS, @new_acronyms;
  $acronym_regexp = array_to_regexp(@ABBREVIATIONS);
}
sub get_acronyms() is export {return @ABBREVIATIONS;}
sub set_acronyms(*@new_acronyms) is export {
  @ABBREVIATIONS=@new_acronyms;
  $acronym_regexp = array_to_regexp(@ABBREVIATIONS);
}
sub get_EOS() is export {return $EOS;}
sub set_EOS(Str $end_marker) is export {$EOS=$end_marker;}

#------------------------------------------------------------------------------
# get_sentences - takes text input and splits it into sentences.
# A regular expression cuts viciously the text into sentences, 
# and then a list of rules (some of them consist of a list of abbreviations)
# is applied on the marked text in order to fix end-of-sentence markings on 
# places which are not indeed end-of-sentence.
#------------------------------------------------------------------------------
sub get_sentences(Str $text) is export {
  my @sentences;
  if ($text.defined) {
    my $quoteless_text;
    my @quotes;
    ($quoteless_text, @quotes) = hide_quotes($text);
    my $marked_text = first_sentence_breaking($quoteless_text);
    my $fixed_marked_text = remove_false_end_of_sentence($marked_text);
    my $quoteful_text = show_quotes($fixed_marked_text,@quotes);
    @sentences = clean_sentences(split(/$EOS/,$quoteful_text));
  }
  return @sentences;
}

#------------------------------------------------------------------------------
# augmenting the default Str class with a .sentences methods, 
# for extra convenience. Sweet!
#------------------------------------------------------------------------------
use MONKEY-TYPING;
augment class Str { method sentences { return get_sentences(self); } }

#==============================================================================
#
# Private methods
#
#==============================================================================

## Please email me any suggestions for optimizing these RegExps.

# Compile the abbreviations array into a regexp, to gain performance
sub array_to_regexp(Str @a) {
  # <$acronym_regexp> doesn't play nice with :i for now... working around it:
  return EVAL("rx:i/" ~ array_to_rxstring(@a) ~ "/;");
}
sub array_to_rxstring(Str @a) {
  return '' if @a.elems < 1;
  my @group = (shift @a);
  my $lead_letter = @group[0].substr(0,1);
  while (@a.elems and  (@a[0].substr(0,1) eq $lead_letter)) {
    push @group, (shift @a);
  }
  my Str $regexp_head;
  if (@group.elems > 1) {
    my Str @subgroup = @group.map:{$_.substr(1,*-0)};
    my $modifier='';
    if (@subgroup[0].chars < 1 ) { $modifier='?';}
    @subgroup = @subgroup.grep({$_.chars > 0});
    # Recurse if multiple acronyms share the lead letter:
    if (@subgroup.elems > 0) {
      $regexp_head = $lead_letter ~ "[" ~ array_to_rxstring(@subgroup) ~ "]" ~  $modifier; }
    else {
      $regexp_head = @group[0];
    }
  } else {
    $regexp_head = @group[0];
  }
  my Str $regexp_tail = array_to_rxstring(@a);
  return $regexp_tail ?? $regexp_head ~ '||' ~ $regexp_tail !! $regexp_head;
}

sub remove_false_end_of_sentence(Str $request) {
  ## don't split at u.s.a.
  my $s = $request;
  $s ~~ s:g/(<!&alphad>.<.alpha>(<&termpunct>[<&AP><space>]?))$EOS/$0/;
  # don't split after a white-space followed by a single letter followed
  # by a dot followed by another whitespace.
  $s ~~ s:g/(<.space><.alpha>'.'<.space>+)$EOS/$0/;

  # fix: bla bla... yada yada
  $s ~~ s:g/'...' $EOS <lower>/...$<lower>/;
  ## fix "." "?" "!"
  $s ~~ s:g/(<['"]><&termpunct><['"]><.space>)$EOS/$0/;
  ## fix where abbreviations exist
  $s ~~ s:g:i/<<(<$acronym_regexp> <&PAP> <.space>)$EOS/$0/;
  ## don't break after quote unless its a capital letter.
  ## TODO: Need to work on balanced quotes, currently they fail.
  $s ~~ s:g/(<["']><.space>*)$EOS(<.space>*<.lower>)/$0$1/;

  ## don't break: text . . some more text.
  $s ~~ s:g/(<.space>'.'<.space>)$EOS(<.space>)/$0$1/;
  $s ~~ s:g/(<.space><&PAP><.space>)$EOS/$0/;

  return $s;
}

sub mark_splits(Str $request) {
  my $text = $request;
  $text ~~ s:g/(\D\d+)<termpunct>(<.space>+)/$0$<termpunct>$EOS$1/;
  $text ~~ s:g/(<.PAP><.space>)(<.space>*\()/$0$EOS$1/;
  $text ~~ s:g/(<[']><.alpha><.termpunct>)<space>/$0$EOS$<space>/;
  $text ~~ s:g:i/(<.space>'no.')(<.space>+)<!before \d>/$0$EOS$1/;
  ##	# split where single capital letter followed by dot makes sense to break.
  ##	# notice these are exceptions to the general rule NOT to split on single
  ##	# letter.
  ##	# notice also that sibgle letter M is missing here due to French 'mister'
  ##	# which is representes as M.
  ##	#
  ##	# the rule will not split on names begining or containing 
  ##	# single capital letter dot in the first or second name
  ##	# assuming 2 or three word name.
  ##	$text=~s/(<.space><lower><.alpha>+<.space>+<-[<upper>M]>'.')(?!<.space>+<upper>'.')/$1$EOS/sg;

 # add EOS when you see "a.m." or "p.m." followed by a capital letter.
 $text ~~ s:g/(<[ap]>'.m.'<.space>+)<upper>/$0$EOS$<upper>/;
  return $text;
}

sub clean_sentences(@sentences) {
  return @sentences.grep({.defined and .match(/<.alpha>/)}).map:{.trim };
}

sub first_sentence_breaking(Str $request) {
  my $text = $request;
  $text ~~ s:g/\n<.space>*\n/$EOS/;
  $text ~~ s:g/(<&PAP><.space>)/$0$EOS/;
  $text ~~ s:g/(<.space><.alpha><&termpunct>)/$0$EOS/; # breake also when single letter comes before punc.
  $text ~~ s:g/(<.alpha><.space><&termpunct>)/$0$EOS/; # Typos such as " arrived .Then "
  return $text;
}


sub hide_quotes(Str $request) {
  my $text = $request;
  my Str @quotes;
  while ($text ~~ s/('"' <-["]>+ '"')/XXXQUOTELESSXXX/) {
    @quotes.push($0.Str);
  }
  return ($text,@quotes);
}

sub show_quotes(Str $request, @quotes) {
  my $text = $request;
  if (@quotes.elems > 0) {
    my $quote = @quotes.shift;
    while ($text ~~ s/'XXXQUOTELESSXXX'/$quote/) {
      $quote = @quotes.shift;
    }
  }
  return $text;
}

=begin pod

=head1 NAME

Lingua::EN::Sentence - Module for splitting text into sentences.

=head1 SYNOPSIS

	use Lingua::EN::Sentence;
	add_acronyms('lt','gen');  ## adding support for 'Lt. Gen.'
        # Perl5 API:
	my @sentences=get_sentences($text);
        # Perl6 API:
        my @sentences=$text.sentences; # Needs a Str $text

	foreach my @sentences -> $sentence {
		## do something with $sentence
	}

=head1 DESCRIPTION

The C<Lingua::EN::Sentence> module contains the function get_sentences, which splits text into its constituent sentences, based on a regular expression and a list of abbreviations (built in and given).

Certain well know exceptions, such as abreviations, may cause incorrect segmentations.  But some of them are already integrated into this code and are being taken care of.  Still, if you see that there are words causing the get_sentences() to fail, you can add those to the module, so it notices them.

=head1 ALGORITHM

Before any regex processing, quotations are hidden away and inserted after the sentences are split. That entails that no sentence splitting will be attempted between pairs of double quotes.

Basically, I use a 'brute' regular expression to split the text into sentences.  (Well, nothing is yet split - I just mark the end-of-sentence).  Then I look into a set of rules which decide when an end-of-sentence is justified and when it's a mistake. In case of a mistake\, the end-of-sentence mark is removed. 

What are such mistakes? Cases of abbreviations, for example. I have a list of such abbreviations (Please see `Acronym/Abbreviations list' section), and more general rules (for example, the abbreviations 'i.e.' and '.e.g.' need not to be in the list as a special rule takes care of all single letter abbreviations).

=head1 FUNCTIONS

=head2 $text.sentences

A very convenient extension to the Perl6 Str string type, 
  the .sentences method allows to natively request the sentences in a string,
  similarly to the Str "words" method.

This is the recommended method when writing Perl6.

=head2 get_sentences( Str $text )

The get sentences function takes a Str variable containing the text
  as an argument and returns an array of sentences that the text has been
  split into.

  Returned sentences will be trimmed (beginning and end of sentence) of
  white-spaces.

  Strings with no alpha-numeric characters in them, won't be returned as sentences.

=head2 add_acronyms( @acronyms )

This function is used for adding acronyms not supported by this code.
  Please see `Acronym/Abbreviations list' section for the abbreviations 
  already supported by this module.

=head2 get_acronyms()

This function will return the defined list of acronyms.

=head2 set_acronyms( @my_acronyms )

This function replaces the predefined acroym list with the given list.

=head2 get_EOS()

This function returns the value of the string used to mark the end of sentence. You might want to see what it is, and to make sure your text doesn't contain it. You can use set_EOS() to alter the end-of-sentence string to whatever you desire.

=head2 set_EOS( $new_EOS_string )

This function alters the end-of-sentence string used to mark the end of sentences.

=head1 Acronym/Abbreviations list

You can use the get_acronyms() function to get acronyms.
It has become too long to specify in the documentation.

If I come across a good general-purpose list - I'll incorporate it into this module.
Feel free to suggest such lists.

=head1 FUTURE WORK

[1] Object Oriented like usage
[2] Supporting more than just English/French
[3] Code optimization. Currently everything is RE based and not so optimized RE
[4] Possibly use more semantic heuristics for detecting a beginning of a sentence
[5] "is rw" text variables. Right now the text gets copied several times which is unnecessary overhead.

=head1 SEE ALSO

	Text::Sentence

=head1 AUTHOR

Deyan Ginev, 2013.

Perl5 CPAN author:
 Shlomo Yona (shlomo@cs.haifa.ac.il)

Released under the same terms as Perl 6; see the LICENSE file for details.

=end pod
