# Blend

[![ci](https://github.com/mimiquate/blend/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/mimiquate/blend/actions?query=branch%3Amain)
[![Hex.pm](https://img.shields.io/hexpm/v/blend.svg)](https://hex.pm/packages/blend)
[![Docs](https://img.shields.io/badge/docs-gray.svg)](https://hexdocs.pm/blend)

Generates and maintains multiple lockfiles so that you can test your elixir app
against different variations of your dependencies

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `blend` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:blend, "~> 0.1.2"}
  ]
end
```

## Usage

```
$ mix blend.init
```

Edit and set your blends in auto-generated `blend.exs` file.

```
$ mix blend.get
```

to generate lockfiles with variations of your dependencies.

See your new extra lockfiles listed under `/blend` folder.

Edit and set custom `lockfile`, `deps_path`, and `build_path` options in your `mix.exs` project,

Also you probably want to ignore `/blend/_build` and `/blend/deps` in your `.gitignore`.

## License

Copyright 2024 Mimiquate

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
