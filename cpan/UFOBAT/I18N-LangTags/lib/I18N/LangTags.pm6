use v6.c;
unit class I18N::LangTags:ver<0.1.0>;
use I18N::LangTags::Grammar;
use I18N::LangTags::Actions;

my $actions = I18N::LangTags::Actions.new();
my regex ix { ['i' | 'x' ] }

sub is_language_tag(Str:D $tag --> Bool) is export {
    return so I18N::LangTags::Grammar.parse($tag, :rule('langtag'))
}

sub extract_language_tags(Str:D $text --> Seq) is export {
    return I18N::LangTags::Grammar.parse(
        $text,
        :rule('scan_langtags'),
        :$actions).made
}

sub same_language_tag(Str:D $tag1, Str:D $tag2 --> Bool) is export {
    return encode_language_tag($tag1) eq encode_language_tag($tag2)
        if is_language_tag($tag1) and is_language_tag($tag2);
    return False;
}

sub similarity_language_tag(Str:D $tag1, Str:D $tag2 --> Int) is export {
    return Int unless is_language_tag($tag1) and is_language_tag($tag2);
    return 0 unless is_language_tag($tag1) or is_language_tag($tag2);

    my @subtags1 = encode_language_tag($tag1).split('-');
    my @subtags2 = encode_language_tag($tag2).split('-');

    my Int $similarity = 0;
    for (@subtags1 Z[eq] @subtags2) -> $similar {
        if $similar {
            $similarity++;
        } else {
            return $similarity;
        }
    }
    return $similarity;
}

sub is_dialact_of(Str:D $tag1, Str:D $tag2 --> Bool) is export {
    my $lang1 = encode_language_tag($tag1);
    my $lang2 = encode_language_tag($tag2);

    return Bool if !is_language_tag($lang1) && !is_language_tag($lang2);
    return False if !is_language_tag($lang1) or !is_language_tag($lang2);

    return True if $lang1 eq $lang2;
    return False if $lang1.chars < $lang2.chars;

    $lang1 ~= '-';
    $lang2 ~= '-';
    return $lang1.substr(0, $lang2.chars) eq $lang2;
}

sub super_languages(Str:D $tag --> Seq) is export {
    return () unless is_language_tag($tag);
    # a hack for those annoying new (2001) tags:
    $tag ~~ s:i/ ^ 'nb' <|w> / 'no-bok' /; # yes, backwards
    $tag ~~ s:i/ ^ 'nn' <|w> / 'no-nyn' /; # yes, backwards
    $tag ~~ s:i/ ^ <ix> ( '-hakka' <|w> ) / 'zh' $1 /; # goes the right way
    # i-hakka-bork-bjork-bjark => zh-hakka-bork-bjork-bjark

    my @supers;
    for $tag.split('-') -> $bit {
        @supers.push( @supers.elems > 0 ?? @supers[*-1] ~ '-' ~ $bit !! $bit);
    };
    pop @supers if @supers;
    shift @supers if @supers and @supers[0] ~~ m:i/ ^ <ix> $ /;
    return @supers.reverse();
}

sub locale2language_tag(Str:D $locale is copy --> Str) is export {
    return $locale if is_language_tag($locale);
    $locale ~~ s:g/ '_' /-/;
    $locale ~~ s/ [ ['.'|'@'] [ <alnum> | '-' ]+]+ $ //;
    return $locale if is_language_tag($locale);
    return Str;
}

sub encode_language_tag(Str:D $tag is copy --> Str) is export {
    # Only similarity_language_tag() is allowed to analyse encodings!
    ## Changes in the language tagging standards may have to be reflected here.
    return Str unless is_language_tag($tag);

    # For the moment, these legacy variances are few enough that
    #  we can just handle them here with regexps.

    $tag ~~ s:i/ ^ 'iw'           <|w> /he/; # Hebrew
    $tag ~~ s:i/ ^ 'in'           <|w> /id/; # Indonesian
    $tag ~~ s:i/ ^ 'cre'          <|w> /cr/; # Cree
    $tag ~~ s:i/ ^ 'jw'           <|w> /jv/; # Javanese
    $tag ~~ s:i/ ^ <ix> '-lux'    <|w> /lb/; # Luxemburger
    $tag ~~ s:i/ ^ <ix> '-navajo' <|w> /nv/; # Navajo
    $tag ~~ s:i/ ^ 'ji'           <|w> /yi/; # Yiddish

    # SMB 2003 -- Hm.  There's a bunch of new XXX->YY variances now,
    #  but maybe they're all so obscure I can ignore them.   "Obscure"
    #  meaning either that the language is obscure, and/or that the
    #  XXX form was extant so briefly that it's unlikely it was ever
    #  used.  I hope.
    #
    # These go FROM the simplex to complex form, to get
    #  similarity-comparison right.  And that's okay, since
    #  similarity_language_tag is the only thing that
    #  analyzes our output.
    $tag ~~ s:i/ ^ <ix> '-hakka' <|w> /zh-hakka/;  # Hakka
    $tag ~~ s:i/ ^ 'nb'          <|w> /no-bok/;    # BACKWARDS for Bokmal
    $tag ~~ s:i/ ^ 'nn'          <|w> /no-nyn/;    # BACKWARDS for Nynorsk

    # Just lop off any leading "x/i-"
    $tag ~~ s:i/ ^ <ix> '-' //;
    return "~" ~ uc($tag);
}

sub alternate_language_tags(Str:D $tag --> List) is export {
    return () unless is_language_tag($tag);
    my @em;

    if    $tag ~~ m:i/ ^ <ix> '-hakka' <|w> (.*)/ { push @em, "zh-hakka$0"; }
    elsif $tag ~~ m:i/ ^ 'zh-hakka' <|w> (.*)/ {    push @em, "x-hakka$0", "i-hakka$0"; }
    elsif $tag ~~ m:i/ ^ 'he' <|w> (.*)/ {          push @em, "iw$0"; }
    elsif $tag ~~ m:i/ ^ 'iw' <|w>(.*)/ {           push @em, "he$0"; }
    elsif $tag ~~ m:i/ ^ 'in' <|w>(.*)/ {           push @em, "id$0"; }
    elsif $tag ~~ m:i/ ^ 'id' <|w>(.*)/ {           push @em, "in$0"; }
    elsif $tag ~~ m:i/ ^ <ix> '-lux' <|w>(.*)/ {    push @em, "lb$0"; }
    elsif $tag ~~ m:i/ ^ 'lb' <|w>(.*)/ {           push @em, "i-lux$0", "x-lux$0"; }
    elsif $tag ~~ m:i/ ^ <ix> '-navajo' <|w>(.*)/ { push @em, "nv$0"; }
    elsif $tag ~~ m:i/ ^ 'nv' <|w>(.*)/ {           push @em, "i-navajo$0", "x-navajo$0"; }
    elsif $tag ~~ m:i/ ^ 'yi' <|w>(.*)/ {           push @em, "ji$0"; }
    elsif $tag ~~ m:i/ ^ 'ji' <|w>(.*)/ {           push @em, "yi$0"; }
    elsif $tag ~~ m:i/ ^ 'nb' <|w>(.*)/ {           push @em, "no-bok$0"; }
    elsif $tag ~~ m:i/ ^ 'no-bok' <|w>(.*)/ {       push @em, "nb$0"; }
    elsif $tag ~~ m:i/ ^ 'nn' <|w>(.*)/ {           push @em, "no-nyn$0"; }
    elsif $tag ~~ m:i/ ^ 'no-nyn' <|w>(.*)/ {       push @em, "nn$0"; }

    state %alt = (
        i => 'x',
        x => 'i',
    );
    push @em, %alt{ $1.lc()} ~ $2 if $tag ~~ m:i/^ (<ix>) ('-' .+)/;
    return @em;
}

my sub init_panic(--> Hash) is pure {
    my %panic;
    for (
        # MUST all be lowercase!
        # Only large ("national") languages make it in this list.
        #  If you, as a user, are so bizarre that the /only/ language
        #  you claim to accept is Galician, then no, we won't do you
        #  the favor of providing Catalan as a panic-fallback for
        #  you.  Because if I start trying to add "little languages" in
        #  here, I'll just go crazy.

        # Scandinavian lgs.  All based on opinion and hearsay.
        'sv'       => <nb no da nn>,
        'da'       => <nb no sv nn>, # I guess
        <no nn nb> => <no nn nb sv da>,
        'is'       => <da sv no nb nn>,
        'fo'       => <da is no nb nn sv>, # I guess

        # I think this is about the extent of tolerable intelligibility
        #  among large modern Romance languages.
        'pt' => <es ca it fr>, # Portuguese, Spanish, Catalan, Italian, French
        'ca' => <es pt it fr>,
        'es' => <ca it fr pt>,
        'it' => <es fr ca pt>,
        'fr' => <es it ca pt>,

        # Also assume that speakers of the main Indian languages prefer
        #  to read/hear Hindi over English
        <as bn gu kn ks kok ml mni mr ne or pa sa sd te ta ur> => 'hi',

        # Assamese, Bengali, Gujarati, [Hindi,] Kannada (Kanarese), Kashmiri,
        # Konkani, Malayalam, Meithei (Manipuri), Marathi, Nepali, Oriya,
        # Punjabi, Sanskrit, Sindhi, Telugu, Tamil, and Urdu.
        'hi' => <bn pa as or>,

        # I welcome finer data for the other Indian languages.
        #  E.g., what should Oriya's list be, besides just Hindi?
        # And the panic languages for English is, of course, nil!

        # My guesses at Slavic intelligibility:
        Pair.new( |( <ru be uk> xx 2)),   # Russian, Belarusian, Ukranian
        Pair.new( |( <sr hr bs> xx 2)),  # Serbian, Croatian, Bosnian
        'cs' => 'sk', 'sk' => 'cs', # Czech + Slovak
        'ms' => 'id', 'id' => 'ms', # Malay + Indonesian
        'et' => 'fi', 'fi' => 'et', # Estonian + Finnish
        #?? 'lo' => 'th', 'th' => 'lo', # Lao + Thai
    ) {
        my ($keys, $vals) = .kv;
        for |$keys -> $k {
            for |$vals -> $v {
                %panic{ $k }.push: $v;
            }
        }
    }
    return %panic;
}

sub panic_languages(*@tags --> Seq) is export {
    # When in panic or in doubt, run in circles, scream, and shout!
    state %panic = init_panic();
    my @out = <en>;
    for @tags -> $tag {
        @out.push: |$_ with %panic{$tag};
    }
    return @out.unique;
}

sub implicate_supers(*@tags --> Seq) is export {
    my @languages = @tags.grep({ is_language_tag($_) });
    my $seen = SetHash.new: @languages.map({ encode_language_tag($_) });
    my @out;

    for @languages -> $lang {
        @out.push: $lang;
        for super_languages($lang) {
            last if encode_language_tag($_) ∈ $seen;
            @out.push: $_;
        }
    }

    return @out.unique;
}

sub implicate_supers_strictly(*@tags --> Seq) is export {
    my @languages = @tags.grep({ is_language_tag($_) });
    my @out = @languages;

    for @languages -> $lang {
        @out.append: super_languages($lang);
    }
    return @out.unique;
}

=begin pod

=head1 NAME

I18N::LangTags - ported from Perl5

=head1 SYNOPSIS

  use I18N::LangTags;

=head1 DESCRIPTION

Language tags are a formalism, described in RFC 3066 (obsoleting
1766), for declaring what language form (language and possibly
dialect) a given chunk of information is in.

This library provides functions for common tasks involving language
tags as they are needed in a variety of protocols and applications.

Please see the "See Also" references for a thorough explanation
of how to correctly use language tags.

=head1 FUNCTIONS

=begin item
C<<is_language_tag(Str:D $lang1 --> Bool)>>

Returns C<True> if C<$lang1> is a formally valid language tag.

   is_language_tag("fr")              # is True
   is_language_tag("x-jicarilla")     # is False
   # Subtags can be 8 chars long at most -- 'jicarilla' is 9

   is_language_tag("sgn-US")          # is True
   # That's American Sign Language

   is_language_tag("i-Klikitat")      # is True
   # True without regard to the fact noone has actually
   # registered Klikitat -- it's a formally valid tag

   is_language_tag("fr-patois")       # is True
   # Formally valid -- altho descriptively weak!

   is_language_tag("Spanish")         # is False
   is_language_tag("french-patois")   # is False
   # No good -- first subtag has to be 2 or 3 chars long -- see RFC3066

   is_language_tag("x-borg-prot2532") # is True
   # Yes, subtags can contain digits, as of RFC3066
=end item

=begin item
C<<extract_language_tags(Str:D $text --> Seq)>>

Returns a list of whatever looks like formally valid language tags
in C<$text>.  Not very smart, so don't get too creative with
what you want to feed it.

  extract_language_tags("fr, fr-ca, i-mingo")
  # returns:   ('fr', 'fr-ca', 'i-mingo')

  extract_language_tags("It's like this: I'm in fr -- French!")
  # returns:   ('It', 'in', 'fr')
  # (So don't just feed it any old thing.)
=end item

=begin item
C<<same_language_tag(Str:D $lang1, Str:D $lang2 --> Bool)>>

Returns C<True> if C<$lang1> and C<$lang2> are acceptable variant tags
representing the same language-form.

   same_language_tag('x-kadara', 'i-kadara')  # is True
   #   (The x/i- alternation doesn't matter)
   same_language_tag('X-KADARA', 'i-kadara')  # is True
   #   (...and neither does case)
   same_language_tag('en',       'en-US')     # is False
   #   (all-English is not the SAME as US English)
   same_language_tag('x-kadara', 'x-kadar')   # is False
   #   (these are totally unrelated tags)
   same_language_tag('no-bok',    'nb')       # is True
   #   (no-bok is a legacy tag for nb (Norwegian Bokmal))

C<same_language_tag> works by just seeing whether
C<encode_language_tag($lang1)> is the same as
C<encode_language_tag($lang2)>.

(Yes, I know this function is named a bit oddly.  Call it historic
reasons.)
=end item

=begin item
C<<similarity_language_tag($lang1, $lang2 --> Int)>>

Returns an integer representing the degree of similarity between
tags C<$lang1> and C<$lang2> (the order of which does not matter), where
similarity is the number of common elements on the left,
without regard to case and to x/i- alternation.

   similarity_language_tag('fr', 'fr-ca')           # is 1
   #   (one element in common)
   similarity_language_tag('fr-ca', 'fr-FR')        # is 1
   #   (one element in common)

   similarity_language_tag('fr-CA-joual',
                           'fr-CA-PEI')             # is 2
   similarity_language_tag('fr-CA-joual', 'fr-CA')  # is 2
   #   (two elements in common)

   similarity_language_tag('x-kadara', 'i-kadara')  # is 1
   #   (x/i- doesn't matter)

   similarity_language_tag('en',       'x-kadar')   # is 0
   similarity_language_tag('x-kadara', 'x-kadar')   # is 0
   #   (unrelated tags -- no similarity)

   similarity_language_tag('i-cree-syllabic',
                           'i-cherokee-syllabic')   # is 0
   #   (no B<leftmost> elements in common!)
=end item

=begin item
C<<is_dialect_of(Str:D $lang1, Str:D $lang2 -->Bool)>>

Returns C<True> if language tag C<$lang1> represents a subform of
language tag C<$lang2>.

B<Get the order right!  It doesn't work the other way around!>

   is_dialect_of('en-US', 'en')            # is True
   # (American English IS a dialect of all-English)

   is_dialect_of('fr-CA-joual', 'fr-CA')   # is True
   is_dialect_of('fr-CA-joual', 'fr')      # is True
   # (Joual is a dialect of (a dialect of) French)

   is_dialect_of('en', 'en-US')            # is False
   # (all-English is a NOT dialect of American English)

   is_dialect_of('fr', 'en-CA')            # is False

   is_dialect_of('en',    'en'   )         # is True
   is_dialect_of('en-US', 'en-US')         # is True
   # (these are degenerate cases)

   is_dialect_of('i-mingo-tom', 'x-Mingo') # is True
   #  (the x/i thing doesn't matter, nor does case)

   is_dialect_of('nn', 'no')               # is True
   # (because 'nn' (New Norse) is aliased to 'no-nyn',
   #  as a special legacy case, and 'no-nyn' is a
   #  subform of 'no' (Norwegian))
=end item

=begin item
C<<super_languages(Str:D $lang1 --> Seq)>>

Returns a sequence of language tags that are superordinate tags to C<$lang1>
-- it gets this by removing subtags from the end of C<$lang1> until
nothing (or just "i" or "x") is left.

   super_languages("fr-CA-joual")  # is  ("fr-CA", "fr")

   super_languages("en-AU")  # is  ("en")

   super_languages("en")  # is  empty-list, ()

   super_languages("i-cherokee")  # is  empty-list, ()
   # ...not ("i"), which would be illegal as well as pointless.

If C<$lang1> is not a valid language tag, returns empty-list.

A notable and rather unavoidable problem with this method:
"x-mingo-tom" has an "x" because the whole tag isn't an
IANA-registered tag -- but super_languages('x-mingo-tom') is
('x-mingo') -- which isn't really right, since 'i-mingo' is
registered.  But this module has no way of knowing that.  (But note
that same_language_tag('x-mingo', 'i-mingo') is C<True>.)

More importantly, you assume I<at your peril> that superordinates of
C<$lang1> are mutually intelligible with C<$lang1>.  Consider this
carefully.
=end item

=begin item
C<<locale2language_tag(Str:D $locale_identifier --> Str)>>

This takes a locale name (like "en", "en_US", or "en_US.ISO8859-1")
and maps it to a language tag.  If it's not mappable (as with,
notably, "C" and "POSIX"), this returns empty-list in a list context,
or undef in a scalar context.

   locale2language_tag("en") is "en"

   locale2language_tag("en_US") is "en-US"

   locale2language_tag("en_US.ISO8859-1") is "en-US"

   locale2language_tag("C") is undef or ()

   locale2language_tag("POSIX") is undef or ()

   locale2language_tag("POSIX") is undef or ()

I'm not totally sure that locale names map satisfactorily to language
tags.  Think REAL hard about how you use this.  YOU HAVE BEEN WARNED.

The output is untainted.  If you don't know what tainting is,
don't worry about it.
=end item

=begin item
C<<encode_language_tag(Str:D $lang1 -> Str)>>

This function, if given a language tag, returns an encoding of it such
that:

* tags representing different languages never get the same encoding.

* tags representing the same language always get the same encoding.

* an encoding of a formally valid language tag always is a string
value that is defined, has length, and is true if considered as a
boolean.

Note that the encoding itself is B<not> a formally valid language tag.
Note also that you cannot, currently, go from an encoding back to a
language tag that it's an encoding of.

Note also that you B<must> consider the encoded value as atomic; i.e.,
you should not consider it as anything but an opaque, unanalysable
string value.  (The internals of the encoding method may change in
future versions, as the language tagging standard changes over time.)

C<encode_language_tag> returns C<Str> if given anything other than a
formally valid language tag.

The reason C<encode_language_tag> exists is because different language
tags may represent the same language; this is normally treatable with
C<same_language_tag>, but consider this situation:

You have a data file that expresses greetings in different languages.
Its format is "[language tag]=[how to say 'Hello']", like:

          en-US=Hiho
          fr=Bonjour
          i-mingo=Hau'

And suppose you write a program that reads that file and then runs as
a daemon, answering client requests that specify a language tag and
then expect the string that says how to greet in that language.  So an
interaction looks like:

          greeting-client asks:    fr
          greeting-server answers: Bonjour

So far so good.  But suppose the way you're implementing this is:
B<This is Perl 5 Code>

          my %greetings;
          die unless open(IN, "<", "in.dat");
          while(<IN>) {
            chomp;
            next unless /^([^=]+)=(.+)/s;
            my($lang, $expr) = ($1, $2);
            $greetings{$lang} = $expr;
          }
          close(IN);

at which point %greetings has the contents:

          "en-US"   => "Hiho"
          "fr"      => "Bonjour"
          "i-mingo" => "Hau'"

And suppose then that you answer client requests for language $wanted
by just looking up $greetings{$wanted}.

If the client asks for "fr", that will look up successfully in
%greetings, to the value "Bonjour".  And if the client asks for
"i-mingo", that will look up successfully in %greetings, to the value
"Hau'".

But if the client asks for "i-Mingo" or "x-mingo", or "Fr", then the
lookup in %greetings fails.  That's the Wrong Thing.

You could instead do lookups on $wanted with:
B<This is Perl 5 Code>

          use I18N::LangTags qw(same_language_tag);
          my $response = '';
          foreach my $l2 (keys %greetings) {
            if(same_language_tag($wanted, $l2)) {
              $response = $greetings{$l2};
              last;
            }
          }

But that's rather inefficient.  A better way to do it is to start your
program with:
B<This is Perl 5 Code>

          use I18N::LangTags qw(encode_language_tag);
          my %greetings;
          die unless open(IN, "<", "in.dat");
          while(<IN>) {
            chomp;
            next unless /^([^=]+)=(.+)/s;
            my($lang, $expr) = ($1, $2);
            $greetings{
                        encode_language_tag($lang)
                      } = $expr;
          }
          close(IN);

and then just answer client requests for language $wanted by just
looking up
B<This is Perl 5 Code>

          $greetings{encode_language_tag($wanted)}

And that does the Right Thing.
=end item

=begin item
C<<alternate_language_tags(Str:D $lang1 --> List)>>

This function, if given a language tag, returns all language tags that
are alternate forms of this language tag.  (I.e., tags which refer to
the same language.)  This is meant to handle legacy tags caused by
the minor changes in language tag standards over the years; and
the x-/i- alternation is also dealt with.

Note that this function does I<not> try to equate new (and never-used,
and unusable)
ISO639-2 three-letter tags to old (and still in use) ISO639-1
two-letter equivalents -- like "ara" -> "ar" -- because
"ara" has I<never> been in use as an Internet language tag,
and RFC 3066 stipulates that it never should be, since a shorter
tag ("ar") exists.

Examples:

  alternate_language_tags('no-bok')       # is ('nb')
  alternate_language_tags('nb')           # is ('no-bok')
  alternate_language_tags('he')           # is ('iw')
  alternate_language_tags('iw')           # is ('he')
  alternate_language_tags('i-hakka')      # is ('zh-hakka', 'x-hakka')
  alternate_language_tags('zh-hakka')     # is ('i-hakka', 'x-hakka')
  alternate_language_tags('en')           # is ()
  alternate_language_tags('x-mingo-tom')  # is ('i-mingo-tom')
  alternate_language_tags('x-klikitat')   # is ('i-klikitat')
  alternate_language_tags('i-klikitat')   # is ('x-klikitat')

This function returns empty-list if given anything other than a formally
valid language tag.
=end item

=begin item
C<<panic_languages(@accept_languages -> Seq)>>

This function takes a list of 0 or more language
tags that constitute a given user's Accept-Language list, and
returns a list of tags for I<other> (non-super)
languages that are probably acceptable to the user, to be
used I<if all else fails>.

For example, if a user accepts only 'ca' (Catalan) and
'es' (Spanish), and the documents/interfaces you have
available are just in German, Italian, and Chinese, then
the user will most likely want the Italian one (and not
the Chinese or German one!), instead of getting
nothing.  So C<panic_languages('ca', 'es')> returns
a list containing 'it' (Italian).

English ('en') is I<always> in the return list, but
whether it's at the very end or not depends
on the input languages.  This function works by consulting
an internal table that stipulates what common
languages are "close" to each other.

A useful construct you might consider using is:

  @fallbacks = super_languages(@accept_languages);
  @fallbacks.append:  panic_languages(
    |@accept_languages, |@fallbacks,
  );
=end item

=begin item
C<<implicate_supers(@languages --> Seq)>>

This takes a list of strings (which are presumed to be language-tags;
strings that aren't, are ignored); and after each one, this function
inserts super-ordinate forms that don't already appear in the list.
The original list, plus these insertions, is returned.

In other words, it takes this:

  pt-br de-DE en-US fr pt-br-janeiro

and returns this:

  pt-br pt de-DE de en-US en fr pt-br-janeiro

This function is most useful in the idiom. B<But detect() is not jet implemented>.

  implicate_supers( I18N::LangTags::Detect::detect() );

=end item

=begin item
C<<implicate_supers_strictly(@languages --> Seq)>>

This works like C<implicate_supers> except that the implicated
forms are added to the end of the return list.

In other words, implicate_supers_strictly takes a list of strings
(which are presumed to be language-tags; strings that aren't, are
ignored) and after the whole given list, it inserts the super-ordinate forms
of all given tags, minus any tags that already appear in the input list.

In other words, it takes this:

  pt-br de-DE en-US fr pt-br-janeiro

and returns this:

  pt-br de-DE en-US fr pt-br-janeiro pt de en

The reason this function has "_strictly" in its name is that when
you're processing an Accept-Language list according to the RFCs, if
you interpret the RFCs quite strictly, then you would use
implicate_supers_strictly, but for normal use (i.e., common-sense use,
as far as I'm concerned) you'd use implicate_supers.
=end item

=head1 SEE ALSO

* L<https://metacpan.org/pod/I18N::LangTags>

* L<I18N::LangTags::List|I18N::LangTags::List>

* RFC 3066, C<http://www.ietf.org/rfc/rfc3066.txt>, "Tags for the
Identification of Languages".  (Obsoletes RFC 1766)

* RFC 2277, C<http://www.ietf.org/rfc/rfc2277.txt>, "IETF Policy on
Character Sets and Languages".

* RFC 2231, C<http://www.ietf.org/rfc/rfc2231.txt>, "MIME Parameter
Value and Encoded Word Extensions: Character Sets, Languages, and
Continuations".

* RFC 2482, C<http://www.ietf.org/rfc/rfc2482.txt>,
"Language Tagging in Unicode Plain Text".

* Locale::Codes, in
C<http://www.perl.com/CPAN/modules/by-module/Locale/>

* ISO 639-2, "Codes for the representation of names of languages",
including two-letter and three-letter codes,
C<http://www.loc.gov/standards/iso639-2/php/code_list.php>

* The IANA list of registered languages (hopefully up-to-date),
C<http://www.iana.org/assignments/language-tags>

=head1 AUTHOR

Martin Barth <martin@senfdax.de>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Martin Barth

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
