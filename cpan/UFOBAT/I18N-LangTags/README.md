[![Build Status](https://travis-ci.org/ufobat/p6-I18N-LangTags.svg?branch=master)](https://travis-ci.org/ufobat/p6-I18N-LangTags)

NAME
====

I18N::LangTags - ported from Perl5

SYNOPSIS
========

    use I18N::LangTags;

DESCRIPTION
===========

Language tags are a formalism, described in RFC 3066 (obsoleting 1766), for declaring what language form (language and possibly dialect) a given chunk of information is in.

This library provides functions for common tasks involving language tags as they are needed in a variety of protocols and applications.

Please see the "See Also" references for a thorough explanation of how to correctly use language tags.

FUNCTIONS
=========

  * `is_language_tag(Str:D $lang1 --> Bool)`

    Returns `True` if `$lang1` is a formally valid language tag.

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

  * `extract_language_tags(Str:D $text --> Seq)`

    Returns a list of whatever looks like formally valid language tags in `$text`. Not very smart, so don't get too creative with what you want to feed it.

        extract_language_tags("fr, fr-ca, i-mingo")
        # returns:   ('fr', 'fr-ca', 'i-mingo')

        extract_language_tags("It's like this: I'm in fr -- French!")
        # returns:   ('It', 'in', 'fr')
        # (So don't just feed it any old thing.)

  * `same_language_tag(Str:D $lang1, Str:D $lang2 --> Bool)`

    Returns `True` if `$lang1` and `$lang2` are acceptable variant tags representing the same language-form.

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

    `same_language_tag` works by just seeing whether `encode_language_tag($lang1)` is the same as `encode_language_tag($lang2)`.

    (Yes, I know this function is named a bit oddly. Call it historic reasons.)

  * `similarity_language_tag($lang1, $lang2 --> Int)`

    Returns an integer representing the degree of similarity between tags `$lang1` and `$lang2` (the order of which does not matter), where similarity is the number of common elements on the left, without regard to case and to x/i- alternation.

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

  * `is_dialect_of(Str:D $lang1, Str:D $lang2 -->Bool)`

    Returns `True` if language tag `$lang1` represents a subform of language tag `$lang2`.

    **Get the order right! It doesn't work the other way around!**

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

  * `super_languages(Str:D $lang1 --> Seq)`

    Returns a sequence of language tags that are superordinate tags to `$lang1` -- it gets this by removing subtags from the end of `$lang1` until nothing (or just "i" or "x") is left.

        super_languages("fr-CA-joual")  # is  ("fr-CA", "fr")

        super_languages("en-AU")  # is  ("en")

        super_languages("en")  # is  empty-list, ()

        super_languages("i-cherokee")  # is  empty-list, ()
        # ...not ("i"), which would be illegal as well as pointless.

    If `$lang1` is not a valid language tag, returns empty-list.

    A notable and rather unavoidable problem with this method: "x-mingo-tom" has an "x" because the whole tag isn't an IANA-registered tag -- but super_languages('x-mingo-tom') is ('x-mingo') -- which isn't really right, since 'i-mingo' is registered. But this module has no way of knowing that. (But note that same_language_tag('x-mingo', 'i-mingo') is `True`.)

    More importantly, you assume *at your peril* that superordinates of `$lang1` are mutually intelligible with `$lang1`. Consider this carefully.

  * `locale2language_tag(Str:D $locale_identifier --> Str)`

    This takes a locale name (like "en", "en_US", or "en_US.ISO8859-1") and maps it to a language tag. If it's not mappable (as with, notably, "C" and "POSIX"), this returns empty-list in a list context, or undef in a scalar context.

        locale2language_tag("en") is "en"

        locale2language_tag("en_US") is "en-US"

        locale2language_tag("en_US.ISO8859-1") is "en-US"

        locale2language_tag("C") is undef or ()

        locale2language_tag("POSIX") is undef or ()

        locale2language_tag("POSIX") is undef or ()

    I'm not totally sure that locale names map satisfactorily to language tags. Think REAL hard about how you use this. YOU HAVE BEEN WARNED.

    The output is untainted. If you don't know what tainting is, don't worry about it.

  * `encode_language_tag(Str:D $lang1 -> Str)`

    This function, if given a language tag, returns an encoding of it such that:

    * tags representing different languages never get the same encoding.

    * tags representing the same language always get the same encoding.

    * an encoding of a formally valid language tag always is a string value that is defined, has length, and is true if considered as a boolean.

    Note that the encoding itself is **not** a formally valid language tag. Note also that you cannot, currently, go from an encoding back to a language tag that it's an encoding of.

    Note also that you **must** consider the encoded value as atomic; i.e., you should not consider it as anything but an opaque, unanalysable string value. (The internals of the encoding method may change in future versions, as the language tagging standard changes over time.)

    `encode_language_tag` returns `Str` if given anything other than a formally valid language tag.

    The reason `encode_language_tag` exists is because different language tags may represent the same language; this is normally treatable with `same_language_tag`, but consider this situation:

    You have a data file that expresses greetings in different languages. Its format is "[language tag]=[how to say 'Hello']", like:

        en-US=Hiho
        fr=Bonjour
        i-mingo=Hau'

    And suppose you write a program that reads that file and then runs as a daemon, answering client requests that specify a language tag and then expect the string that says how to greet in that language. So an interaction looks like:

        greeting-client asks:    fr
        greeting-server answers: Bonjour

    So far so good. But suppose the way you're implementing this is: **This is Perl 5 Code**

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

    And suppose then that you answer client requests for language $wanted by just looking up $greetings{$wanted}.

    If the client asks for "fr", that will look up successfully in %greetings, to the value "Bonjour". And if the client asks for "i-mingo", that will look up successfully in %greetings, to the value "Hau'".

    But if the client asks for "i-Mingo" or "x-mingo", or "Fr", then the lookup in %greetings fails. That's the Wrong Thing.

    You could instead do lookups on $wanted with: **This is Perl 5 Code**

        use I18N::LangTags qw(same_language_tag);
        my $response = '';
        foreach my $l2 (keys %greetings) {
          if(same_language_tag($wanted, $l2)) {
            $response = $greetings{$l2};
            last;
          }
        }

    But that's rather inefficient. A better way to do it is to start your program with: **This is Perl 5 Code**

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

    and then just answer client requests for language $wanted by just looking up **This is Perl 5 Code**

        $greetings{encode_language_tag($wanted)}

    And that does the Right Thing.

  * `alternate_language_tags(Str:D $lang1 --> List)`

    This function, if given a language tag, returns all language tags that are alternate forms of this language tag. (I.e., tags which refer to the same language.) This is meant to handle legacy tags caused by the minor changes in language tag standards over the years; and the x-/i- alternation is also dealt with.

    Note that this function does *not* try to equate new (and never-used, and unusable) ISO639-2 three-letter tags to old (and still in use) ISO639-1 two-letter equivalents -- like "ara" -> "ar" -- because "ara" has *never* been in use as an Internet language tag, and RFC 3066 stipulates that it never should be, since a shorter tag ("ar") exists.

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

    This function returns empty-list if given anything other than a formally valid language tag.

  * `panic_languages(@accept_languages -> Seq)`

    This function takes a list of 0 or more language tags that constitute a given user's Accept-Language list, and returns a list of tags for *other* (non-super) languages that are probably acceptable to the user, to be used *if all else fails*.

    For example, if a user accepts only 'ca' (Catalan) and 'es' (Spanish), and the documents/interfaces you have available are just in German, Italian, and Chinese, then the user will most likely want the Italian one (and not the Chinese or German one!), instead of getting nothing. So `panic_languages('ca', 'es')` returns a list containing 'it' (Italian).

    English ('en') is *always* in the return list, but whether it's at the very end or not depends on the input languages. This function works by consulting an internal table that stipulates what common languages are "close" to each other.

    A useful construct you might consider using is:

        @fallbacks = super_languages(@accept_languages);
        @fallbacks.append:  panic_languages(
          |@accept_languages, |@fallbacks,
        );

  * `implicate_supers(@languages --> Seq)`

    This takes a list of strings (which are presumed to be language-tags; strings that aren't, are ignored); and after each one, this function inserts super-ordinate forms that don't already appear in the list. The original list, plus these insertions, is returned.

    In other words, it takes this:

        pt-br de-DE en-US fr pt-br-janeiro

    and returns this:

        pt-br pt de-DE de en-US en fr pt-br-janeiro

    This function is most useful in the idiom. **But detect() is not jet implemented**.

        implicate_supers( I18N::LangTags::Detect::detect() );

  * `implicate_supers_strictly(@languages --> Seq)`

    This works like `implicate_supers` except that the implicated forms are added to the end of the return list.

    In other words, implicate_supers_strictly takes a list of strings (which are presumed to be language-tags; strings that aren't, are ignored) and after the whole given list, it inserts the super-ordinate forms of all given tags, minus any tags that already appear in the input list.

    In other words, it takes this:

        pt-br de-DE en-US fr pt-br-janeiro

    and returns this:

        pt-br de-DE en-US fr pt-br-janeiro pt de en

    The reason this function has "_strictly" in its name is that when you're processing an Accept-Language list according to the RFCs, if you interpret the RFCs quite strictly, then you would use implicate_supers_strictly, but for normal use (i.e., common-sense use, as far as I'm concerned) you'd use implicate_supers.

SEE ALSO
========

* [https://metacpan.org/pod/I18N::LangTags](https://metacpan.org/pod/I18N::LangTags)

* [I18N::LangTags::List](I18N::LangTags::List)

* RFC 3066, `http://www.ietf.org/rfc/rfc3066.txt`, "Tags for the Identification of Languages". (Obsoletes RFC 1766)

* RFC 2277, `http://www.ietf.org/rfc/rfc2277.txt`, "IETF Policy on Character Sets and Languages".

* RFC 2231, `http://www.ietf.org/rfc/rfc2231.txt`, "MIME Parameter Value and Encoded Word Extensions: Character Sets, Languages, and Continuations".

* RFC 2482, `http://www.ietf.org/rfc/rfc2482.txt`, "Language Tagging in Unicode Plain Text".

* Locale::Codes, in `http://www.perl.com/CPAN/modules/by-module/Locale/`

* ISO 639-2, "Codes for the representation of names of languages", including two-letter and three-letter codes, `http://www.loc.gov/standards/iso639-2/php/code_list.php`

* The IANA list of registered languages (hopefully up-to-date), `http://www.iana.org/assignments/language-tags`

AUTHOR
======

Martin Barth <martin@senfdax.de>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Martin Barth

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

