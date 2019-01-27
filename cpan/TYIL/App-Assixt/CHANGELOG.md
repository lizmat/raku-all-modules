# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic
Versioning](http://semver.org/spec/v2.0.0.html).

## [UNRELEASED]
### Added
- The `meta` subcommand has been extended to work with more fields than just
  `source-url`. The new fields include:
  - `auth`
  - `description`
  - `license`

## [1.0.0] - 2018-09-03
### Added
- The `upload` command now tries multiple attempts to upload a distribution.
  The default number of tries is 3, but can be altered using the `pause.tries`
  configuration key.
- The `api` key in the `META6.json` now gets updated to reflect the major
  version number.
- `dist` requires a `source-url` to be set in the `META6.json`.
- New command, `meta source-url` has been added to update the `source-url` in
  the `META6.json`.
- `new` can now get it's name argument as first positional argument, i.e.:
  `assixt new Foo::Bar`.
- Documentation has been added to the module's pod contents. `p6man` is now
  also pulled in through a dependency on `Pod::To::Pager`, which is the
  recommended method to access the documentation. Take a look: `p6man
  App::Assixt`!

### Changed
- The `.gitlab-ci.yml` generated during `new` should now have the correct names
  for the placeholder, fixing [GitLab#4](https://gitlab.com/tyil/perl6-app-assixt/issues/4).
- The `upload` command now makes use of `CPAN::Uploader::Tiny`.
- The `upload` command will now generate a more specific and friendly error
  message (if possible) as to why uploading failed.
- Error messages have been updated to be more user friendly.

## [0.5.0] - 2018-08-25
### Added
- `touch` will now add a pod structure at the bottom of `bin`, `lib`, `class`
  and `unit` templates.
- `assixt` has been given a pod document for use with `p6man`.
- New projects will now contain a `CHANGELOG.md` file, based on the
  [Keep a Changelog](https://keepachangelog.com/en/1.0.0) specification.
- `touch meta` has been added to create meta file templates, including a `readme`,
  `gitlab-ci` configuration and `gitignore` files.
- An `undepend` command has been added to remove existing dependencies. Note
  that, like any other module related activity, it is case-sensitive on the
  module names.
- New projects will now contain a `README.pod6` file. Module authors are
  encouraged to extend it with some helpful information for end-users.

### Changed
- `bump` will update other files to show the new version number as well:
  - Files referenced in the `provides` key in `META6.json` will have the
    `=VERSION` blocks updated with the new version.
  - The `CHANGELOG.md` file will have it's `UNRELEASED` block changed to the new
    version number with the current date.
- `bootstrap config` should now work as expected again. Some unnecessary keys
  are new being filtered out, and the save mechanism should work properly now.
- `depend` can now correctly be called with multiple arguments.
- `bump` now uses `Version::Semantic` to deal with the version bumping.
- The directory path check in `new` has been updated to be checked earlier, and
  to give users the option to change the name if needed.
- `dist` will now require a `README` or `README.md` file to exist in the module
  root. If a `README.pod6` is found, this will be converted to `README.md` to
  use instead. This is done because Markdown is widely supported on numerous
  platforms.
- `dist` will now strip local user data from the distribution tarball.

## [0.4.0] - 2018-06-24
### Added
- New projects will now contain a sample GitLab CI configuration

## [0.3.0] - 2018-04-21
### Added
- `api` flag added to META6.json

### Changed
- `author` field now defaults to being an array.
- `assixt test` now calls `run` in sink context, to avoid output of a Failure
  when `prove` found failing tests. [GitHub#7](https://github.com/scriptkitties/perl6-app-assixt/issues/7)

## [0.2.4] - 2018-03-29
### Changed
- Update `Config` dependency to greatly improve performance
- Rewrite Command loading to improve performance
- Tests are now all ran again

## [0.2.3] - 2018-03-23
### Changed
- Slow bin tests are now marked as author tests

## [0.2.2] - 2018-03-21
### Changed
- Tests now show a notice to indicate testing will take a long time

## [0.2.1] - 2018-03-21
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
