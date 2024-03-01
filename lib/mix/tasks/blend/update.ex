defmodule Mix.Tasks.Blend.Update do
  @shortdoc "Updates lockfiles from blend.exs"

  @moduledoc """
  A task to update your blend lockfiles dependencies.

  That means, trying to get all the dependencies in each lockfile to their most recent
  version possible respecting the defined version constraints.
  """

  use Mix.Task

  @requirements ["app.config"]

  @impl true
  def run(args) do
    Blend.blends()
    |> Map.keys()
    |> Enum.map(fn blend_id ->
      IO.puts("Updating blend #{blend_id}")

      Blend.within(
        blend_id,
        fn ->
          Mix.Task.rerun("deps.update", args)
        end
      )
    end)
  end
end
