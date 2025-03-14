# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed

- Rearrange blend folders.

### Upgrade Steps

- Change `.gitignore`
```diff
-/blend/_build
-/blend/deps
+/blend/*/_build
+/blend/*/deps
```

- Move existing blend lockfiles and folders
```sh
$ for lock_file in blend/*.mix.lock; do
  blend_name=$(basename "$lock_file" .mix.lock)

  mkdir -p "blend/$blend_name"

  mv "$lock_file" "blend/$blend_name/mix.lock"

 if [ -d "blend/_build/$blend_name" ]; then
   mv "blend/_build/$blend_name" "blend/$blend_name/_build/"
 fi

  if [ -d "blend/deps/$blend_name" ]; then
    mv "blend/deps/$blend_name" "blend/$blend_name/deps/"
  fi
done
```

- If you have `blend/premix.exs` file change it:
```diff
-maybe_put_env.("MIX_LOCKFILE", "blend/#{blend}.mix.lock")
-maybe_put_env.("MIX_DEPS_PATH", "blend/deps/#{blend}")
-maybe_put_env.("MIX_BUILD_ROOT", "blend/_build/#{blend}")
+maybe_put_env.("MIX_LOCKFILE", "blend/#{blend}/mix.lock")
+maybe_put_env.("MIX_DEPS_PATH", "blend/#{blend}/deps")
+maybe_put_env.("MIX_BUILD_ROOT", "blend/#{blend}/_build")
```

- Clean old directories

`$ rm -r blend/deps blend/_build`

- Update CI

  Adding it for completeness
  
  There is no specific change because it depend on how each package implemented CI strategy

## [v0.4.1] - 2024-09-24

### Added

- `mix blend.install` as a rename for `mix blend.init` (soft-deprecated, still works).
- `mix blend.gen.premix` as a rename for `mix blend.premix` (soft-deprecated, still works).

## [v0.4.0] - 2024-08-09

### Added

- `mix blend.clean` to clean stale blend lockfiles and blend build artifacts
- Documentation improvements

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

[v0.4.1]: https://github.com/mimiquate/blend/compare/v0.4.0...v0.4.1/
[v0.4.0]: https://github.com/mimiquate/blend/compare/v0.3.0...v0.4.0/
[v0.3.0]: https://github.com/mimiquate/blend/compare/v0.2.0...v0.3.0/
[v0.2.0]: https://github.com/mimiquate/blend/compare/v0.1.3...v0.2.0/
[v0.1.3]: https://github.com/mimiquate/blend/compare/v0.1.2...v0.1.3/
[v0.1.2]: https://github.com/mimiquate/blend/compare/v0.1.1...v0.1.2/
[v0.1.1]: https://github.com/mimiquate/blend/compare/v0.1.0...v0.1.1/
[v0.1.0]: https://github.com/mimiquate/blend/releases/tag/v0.1.0
