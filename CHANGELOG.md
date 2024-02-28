# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.3.0] - 2024-02-28

### Added

- `mix blend.premix` task to auto generate `premix.exs` file to help in configuring the `BLEND` env var

## [v0.2.1] - 2024-02-26

### Added

- Support elixir 1.13+

## [v0.2.0] - 2024-02-23

### Added

- `mix blend.list`
- `mix blend.clean`

## [v0.1.3] - 2024-02-15

### Added

- Support elixir 1.14+
- Better IO messaging when running blend tasks

## [v0.1.2] - 2024-02-08

### Fixed

- `mix blend.get` on first run (when `_build` folder is empty) now works

## [v0.1.1] - 2024-02-06

### Added

- `mix blend.update`

## [v0.1.0] - 2024-02-06

### Added

- `mix blend.init`
- `mix blend.get`

[v0.2.0]: https://github.com/mimiquate/blend/compare/v0.1.3...v0.2.0/
[v0.1.3]: https://github.com/mimiquate/blend/compare/v0.1.2...v0.1.3/
[v0.1.2]: https://github.com/mimiquate/blend/compare/v0.1.1...v0.1.2/
[v0.1.1]: https://github.com/mimiquate/blend/compare/v0.1.0...v0.1.1/
[v0.1.0]: https://github.com/mimiquate/blend/releases/tag/v0.1.0
