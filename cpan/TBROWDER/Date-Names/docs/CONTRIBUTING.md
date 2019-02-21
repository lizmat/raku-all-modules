# Contributing

## New language

New languages are always welcome!

To contribute a new language, do the following:

+ Determine the ISO two- or three-letter code for your language. You will
  use the lower-case version of it in the rest of the steps.

  ADD REF

+ Download the following file from the Unicode project:

  ADD REF

+ Use program **gen-lang-pm.p6** with the downloaded archive (it
  be unpacked in the current working directory) which
  will generate a valid **lang.pm6** file suitable for local use
  in a locally forked version of this repo.

+ Determine the ISO two- or three-letter code for your language. You will
  use the lower-case version of it in the rest of the steps.
  See a list of ISO language codes here: [ISO 639-2 alpha 2 language codes](https://www.loc.gov/standards/iso639-2/php/code_list.php).

+ Copy the template file ./resources/xx.pm6 and rename it to
  "lib/Data/Names/xx.pm6" where xx is your language's lower-case ISO
  two-letter code.

+ Fill out the new xx.pm6 file as completely as you can. Please
  feel free to document it as required, but DO NOT change the name or
  number of elements of any of the standard eight arrays.
