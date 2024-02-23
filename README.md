# 🥣 Blend

[![ci](https://github.com/mimiquate/blend/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/mimiquate/blend/actions?query=branch%3Amain)
[![Hex.pm](https://img.shields.io/hexpm/v/blend.svg)](https://hex.pm/packages/blend)
[![Docs](https://img.shields.io/badge/docs-gray.svg)](https://hexdocs.pm/blend)

Test your package against different versions of its dependencies.

Generates and maintains multiple lockfiles so that you can test your package
against different variations of your dependencies versions.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `blend` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:blend, "~> 0.2.0"}
  ]
end
```

## Usage

### 1. Initialization

```
$ mix blend.init
```

### 2. Define your blends

Edit and set your blends in the auto-generated `blend.exs` file.


### 3. Resolve blends and generate lockfiles

```
$ mix blend.get
```

to resolve your blends and generate new lockfiles with variations of your dependencies under the new `/blend` folder.

### 4. Ignore blend build artifacts

Add

```
# .gitignore

/blend/_build
/blend/deps
```

to your `.gitignore` file.

before comitting your changes.


### 5. Running in the context of a blend lockfile

#### Option A. Overriding your `mix.lock`.

If you just need a CI job step to run against a blend lockfile, it might be enough to just:

```
$ mv blend/<blend-name>.mix.lock mix.lock
```

as a CI step before `mix deps.get`.

#### Option B. `BLEND` env var configuration

A more permanent configuration for running mix tasks in the context of a blend lockfile with a simple env var
can be acomplished by customizing your `mix.exs` a bit, with the following steps.

##### 1. Create a new file `blend/premix.exs` with the following contents:

```elixir
# blend/premix.exs

maybe_put_env = fn varname, value ->
  System.put_env(varname, System.get_env(varname, value))
end

blend = System.get_env("BLEND")

if blend && String.length(blend) > 0 do
  maybe_put_env.("MIX_LOCKFILE", "blend/#{blend}.mix.lock")
  maybe_put_env.("MIX_DEPS_PATH", "blend/deps/#{blend}")
  maybe_put_env.("MIX_BUILD_ROOT", "blend/_build/#{blend}")
end
```

##### 2. Add `Code.compile_file("blend/premix.exs")` statement to the top of your `mix.exs`.

```elixir
# mix.exs

Code.compile_file("blend/premix.exs")

defmodule YourApp.MixProject do
  ...

end
```

##### 3. Conditionally set the `lockfile` option in your `mix.exs`'s `def project`.

Something like this would be enough:

```elixir
# mix.exs

defmodule YourApp.MixProject do
  use Mix.Project

  def project do
    [
      ...
    ]
    |> Keyword.merge(maybe_lockfile_option())
  end

  ...

  defp maybe_lockfile_option do
    case System.get_env("MIX_LOCKFILE") do
      nil -> []
      "" -> []
      lockfile -> [lockfile: lockfile]
    end
  end
end
```

##### 4. Enjoy

Now you can run any task, e.g. run your tests, against different lockfiles locally by just executing:

```
$ BLEND=<blend-name> mix test
```

If you need a quick printed list of the available blend names, you can:

```
$ mix blend.list
```

### 6. Updating blend lockfiles

```
$ mix blend.update --all
```

whenever you want to update all your blend lockfiles to latest possible versions.

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
