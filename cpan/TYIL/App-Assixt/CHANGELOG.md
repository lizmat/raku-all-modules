# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic
Versioning](http://semver.org/spec/v2.0.0.html).

## [0.2.2] - 2018-03-10
### Changed
- Tests now show a notice to indicate testing will take a long time

## [0.2.1] - 2018-03-10
### Changed
- Fix a bug which resulted in some commands running twice on a single invocation
- Test suite updated to call the program directly (greatly increases test time, sadly)

## [0.2.0] - 2018-03-20
### Added
- A CHANGELOG is now present to keep track of changes between versions
- USAGE/help can now be invoked using `-h` or `--help` in addition to `help`

### Changed
- Dependency versions are no longer locked to a single version
- The USAGE/help output has been updated to conform to [docopt](http://docopt.org)
- `use` issue resulting in testing bug has been resolved [GitHub#3](https://github.com/scriptkitties/perl6-app-assixt/issues/3)
