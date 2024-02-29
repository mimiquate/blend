defmodule Mix.Tasks.Blend.Get do
  @shortdoc "Generates lockfiles from blend.exs"

  @moduledoc """
  A task to resolve your blends and generate lockfiles.

  That is to say, have blend read your defined blends in `blend.exs` and generate
  a lockfile for each blend by combining each specific blend overrides with your package
  dependencies in `mix.exs`.
  """

  use Mix.Task

  @requirements ["app.config"]

  @impl true
  def run(args) do
    Blend.blends()
    |> Map.keys()
    |> Enum.map(fn blend_id ->
      IO.puts("Resolving blend #{blend_id}")

      Blend.within(
        blend_id,
        fn ->
          Mix.Task.rerun("deps.get", args)
        end
      )
    end)
  end
end
