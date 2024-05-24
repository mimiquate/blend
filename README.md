# 🥣 Blend

[![ci](https://github.com/mimiquate/blend/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/mimiquate/blend/actions?query=branch%3Amain)
[![Hex.pm](https://img.shields.io/hexpm/v/blend.svg)](https://hex.pm/packages/blend)
[![Docs](https://img.shields.io/badge/docs-gray.svg)](https://hexdocs.pm/blend)

Test your package against different versions of its dependencies.

Generates and maintains multiple lockfiles based on your defined variations (a.k.a. blends)
so that you can test your package against different variations of your dependencies versions.

You can read more about the motivation for this project [here](#Motivation).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `blend` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:blend, "~> 0.3.0", only: :dev}
  ]
end
```

## Usage

### 1. Generate `blend.exs`

```
mix blend.init
```

### 2. Define your blends

Edit and set your blends in the `blend.exs` file.

For example, an elixir package that depends on `plug_crypto` with a requirement of `~> 1.2 or ~> 2.0`,
that wants to test against the two major versions, would normally have it's `mix.lock` resolved to
`2.x`, so it would want to define the following:

```elixir
# blend.exs

# Example for testing against plug_crypto 1.x
%{
  plug_crypto_1: [{:plug_crypto, "~> 1.2"}]
}
```

in order for blend to generate an additional lockfile that locks `plug_crypto` to the latest possible
`1.x` supported version.

Map keys define the blend name, used for naming the lockfile, and the dependencies list are
merged with the package dependencies before resolving and generating the lockfile variation.

### 3. Resolve blends and generate lockfiles

```
mix blend.get
```

to resolve your blends and generate new lockfiles with variations of your dependencies under the new `/blend` folder.

```
blend
├── _build
├── deps
├── plug_crypto_1.mix.lock
mix.lock
```

### 4. Ignore blend build artifacts

```diff
 # .gitignore

 ...

+/blend/_build
+/blend/deps
```

Add to your `.gitignore` file, before comitting your changes.


### 5. Running in the context of a blend lockfile

#### Option A. Overriding your `mix.lock`.

If you just need a CI job step to run against a blend lockfile, it might be enough to just:

```
cp blend/plug_crypto_1.mix.lock mix.lock
```

Now you can run any task, e.g. run your tests.

```
mix test
```

#### Option B. `BLEND` env var configuration

A more permanent configuration for running mix tasks in the context of a blend lockfile with a simple env var
can be accomplished by customizing your `mix.exs` a bit, with the following steps.

##### 1. Create a new file `blend/premix.exs` with the following command:

```
mix blend.premix
```

This will generate a `blend/premix.exs` file that needs to be compiled at the top of your `mix.exs` file
so that some mix env vars are properly set based on the `BLEND` env var before running any mix task.

##### 2. Modify your `mix.exs`.

```diff
 # mix.exs

+Code.compile_file("blend/premix.exs")

 defmodule YourApp.MixProject do
   ...
   def project do
     [
       ...
     ]
+    |> Keyword.merge(maybe_lockfile_option())
   end
   ....

+  defp maybe_lockfile_option do
+    case System.get_env("MIX_LOCKFILE") do
+      nil -> []
+      "" -> []
+      lockfile -> [lockfile: lockfile]
+     end
+  end
 end
```

##### 3. Enjoy

Now you can run any task, e.g. run your tests, against different lockfiles locally by just executing:

```
BLEND=plug_crypto_1 mix test
```

## Tasks

```
mix blend.init         # Generate blend.exs
mix blend.get          # Generate blend lockfiles
mix blend.update --all # Update blend lockfiles to latest possible versions
mix blend.list         # List blends
mix blend.clean        # Cleans blends build artifacts and stale lockfiles
mix blend.premix       # Generate premix.exs file
```


## Motivation

At Mimiquate, our engagement with the Elixir ecosystem deeply influences our projects. We’ve benefited immensely from the community’s support and resources. During our development of open-source hex packages, we encountered a challenge: testing across different dependency versions lacked a straightforward approach. This issue led us to think about how we could contribute to the community that has been so supportive of us.

Our background includes Ruby on Rails, where the Ruby community has tackled a similar challenge with the appraisal gem. This tool makes it easier to test various dependency versions and is designed to work well with CI pipelines, reducing the risk of regressions. It’s been really great for developers and has positively impacted the ecosystem’s health.

With that inspiration, we set out to create something for the Elixir community to help streamline development. Our first version doesn’t have all the functionalities of the appraisal gem but establishes a good starting point. It allows developers to test their hex packages against different lock file combinations, which is handy for spotting regressions in common scenarios.

We realize that our current tool doesn’t address every testing scenario. Yet, we’re committed to improving it, aiming to cover more ground and enhance its functionality. Our goal goes beyond just solving a technical issue; we hope to make the development process in the Elixir community more supportive and efficient for everyone.

## Having a hard time finding Elixir talent?

At Mimiquate we have been Elixiring since 2016 and we are true believers in the community and the ecosystem.
If you are looking to turbo charge your Elixir team, [reach out](mailto:contact@mimiquate.com?subject=Elixir%20team%20augmentation)!

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
