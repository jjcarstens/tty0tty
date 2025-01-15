# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.1] - 2025-01-14

### Added

* `TTY0TTY.open/2` now blocks until the pty devices are confirmed open to prevent
  timing errors attempting to read/write before it has finished opening
  (thanks @coop! :heart:)

## [v1.0.0] - 2023-02-24

Initial release to support opening, closing, and listing emulated ports.

[v1.0.0]: https://github.com/jjcarstens/tty0tty/releases/tag/v1.0.0
