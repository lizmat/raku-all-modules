## [v2.0.1] - 2019-02-27
- added missing names to META6.json

## [v2.0.0] - 2019-02-21
- Permanently removed the hashes from lib/Date/Names.pm6
  so the original direct hash access syntax has changed
  (for the better IMHO).
- Changed defaults for the class to English and full names.
- Added a CONTRIBUTING file.
- Added a resources template file. xx.pm6, for contributors
  of a new language.
- Added a "raw" truncation capability for the class when
  using full name hashes.
- Added table titles and numbers.
- Added a new Table 3 showing codes, and their meanings,
  used for Table 2.
- Added full-name hash names to Table 2.
- Added two example files, mainly to check correctness of
  code used in the README file.
- Standardized format of the basic eight hashes for each
  language and created a template file, xx.pm6, in the new
  resources directory.
- Added Indonesian language.
- Added an automated test generator for new languages.
- Removed 'export' from all symbols.
- Added directories 'resources', 'sandbox', and 'docs'.
- Moved all docs but README to docs directory.

## [v1.1.0] - 2019-02-11
- Change description in META6.json file.
- Merged PRs from @moritz (German three-letter abbreviaitons, Norwegian).
- Merged PR from @sena_kun (AKA @Altai-man) (Russian).
- French data from @lucs.
- Merged PR from @lizmat (Dutch)
- Started a class (Date::Names) to handle the names, with a lited set
  of working tests for now.
- Updated README.
- Split hashes into separate modules to facilitate the new class.

## [v1.0.3] - 2019-02-10
- Move version number to top of META6.json file.
- Make tests more efficient and easier to modify.
- Add export to @lang variable.
- Add 'en' to @lang variable.
- Add another PR suggestion for the README.md.

## [v1.0.2] - 2019-02-10
- Fix typos.

## [v1.0.1] - 2019-02-10
- Changed abbreviation hash name format, e.g,
  '%mon-abbrev2' was changed to '%mon2'.
- Added a @lang variable to list ISO two-letter language
  codes for languages currently considered in this
  module.
- Added new tests.
- Renamed one test for clarity.
- Added this log.

## [v1.0.0] - 2019-02-09
- Initial release.
