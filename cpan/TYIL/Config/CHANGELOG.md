# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic
Versioning](http://semver.org/spec/v2.0.0.html).

## [1.3.4] - 2018-03-21
### Removed
- Lingering say statement in get-parser, breaking tests for Rakudo Star users ([GitHub#4](https://github.com/scriptkitties/p6-Config/issues/4))
- Useless `use lib "lib"` statements from tests
- Useless dd statement from tests

## [1.3.3] - 2018-03-20
### Added
- A CHANGELOG is now present to keep track of changes between versions

### Changed
- Fix `:delete` adverb
