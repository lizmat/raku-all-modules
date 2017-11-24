# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [0.1.0]
### Added
- Custom prompts now when attaching to container through ```platform attach ..``` (refs #7)
- Now you can just use part of the container name to attach (refs #7)

### Changed
- All parts renamed from Platform to App::Platform

## [0.0.6]
### Added
- Adjust wrap-text width according to terminal (closes #14)
- You can now set DNS port from the command line (refs #6)
- Git clone support on environment subsystem (closes #8)

### Fixed
- If DNS port is reserved try next one (refs #6)

## [0.0.5]
### Added
- New commandline interface using CommandLine::Usage
- New colourful output format
- ```platform attach <project>``` to connect container via shell
- examples/openldap to use openldap on your environments
- ```platform remove <project>``` command to stop & remove
- Throw exception if project file doesn't exists and catch it for reporting

### Changed
- Added -it params to exec/run command

### Fixed
- Rakudo 2017.04 and up compliance abspath -> absolute
- Usage of ~ on project folder
- File creation fixes when file wanted to be empty
- Misc output cleanups

## [0.0.4]
### Added
- Support for absolute path on project file e.g ```platform --project=<projectdir>/project.yml run```

### Changed
- Sleep on exec changed to be conditional if postgres installed
- Output more verbose and colourful

## [0.0.3] - 2017-04-12
### Added
- Running commands after container is started
- [--network=acme] option to platform command

### Changed
- Be verbose on docker build phase
- Don't wait so much on docker stop

### Fixed
- File creation fixes and finding correct path
- "platform ssl genrsa" wasn't producing public crt
- Replace ~ from path to HOME

## [0.0.2] - 2017-04-05
### Added
- Created basic example under examples/ folder

### Changed
- Default tld domain from local -> localhost
- DNS servers to Google Public DNS servers

### Fixed
- macOS issues on tests

## [0.0.1] - 2017-03-31
### Added
- Proxy + DNS services
- Project and Environment support

[Unreleased]: https://github.com/7ojo/perl6-platform/compare/0.1.0...HEAD
[0.1.0]: https://github.com/7ojo/perl6-platform/compare/0.0.6...0.1.0
[0.0.6]: https://github.com/7ojo/perl6-platform/compare/0.0.5...0.0.6
[0.0.5]: https://github.com/7ojo/perl6-platform/compare/0.0.4...0.0.5
[0.0.4]: https://github.com/7ojo/perl6-platform/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/7ojo/perl6-platform/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/7ojo/perl6-platform/compare/0.0.1...0.0.2
[0.0.1]: https://github.com/7ojo/perl6-platform/compare/0.0.1
