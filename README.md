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
    {:blend, "~> 0.1.3"}
  ]
end
```

## Usage

1.

```
$ mix blend.init
```

Edit and set your blends in the auto-generated `blend.exs` file.

2.

Add

```
/blend/_build
/blend/deps
```

to your `.gitignore`.

3.

```
$ mix blend.get
```

to resolve your blends and generate new lockfiles with variations of your dependencies under the `/blend` folder.

```
$ mix blend.update --all
```

whenever you want to update all your blend lockfiles to latest possible versions.


#### Running task in the context of a lockfile

1. Overriding your `mix.lock`.

Might be enough if you just want to test against different lockfiles in your CI, to

```
mv blend/<blend-name>.mix.lock mix.lock
```

as a CI step before `mix deps.get`.

1. `BLEND` env var configuration

More permanent configuration to be able to just run mix tasks in the context of a lockfile with a simple env var
can be acomplished by customizing a bit your `mix.exs`.

Create a new file under `blend/premix.exs` with the following contents:

```
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

Append `Code.compile_file("blend/premix.exs")` to the top of your `mix.exs` file.

Also conditionally set the `lockfile` option in your `def project`.

Something like this would be enough:

```diff
# In mix.exs

  def project do
    [
      ...
    ]
    |> Keyword.merge(maybe_lockfile_option())
  end

  defp maybe_lockfile_option do
    case System.get_env("MIX_LOCKFILE") do
      nil -> []
      "" -> []
      lockfile -> [lockfile: lockfile]
    end
  end
```

Now you can run any task, e.g. run your tests, against different lockfiles locally by just executing:

```
BLEND=<blend-name> mix test
```

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
