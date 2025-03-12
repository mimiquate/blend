defmodule Mix.Tasks.Blend.Unlock do
  @shortdoc "Unlocks dependencies in blend lockfiles"

  @moduledoc """
  A task to unlock your blend lockfiles dependencies.
  """

  use Mix.Task

  @requirements ["app.config"]

  @impl true
  def run(args) do
    Blend.blends()
    |> Map.keys()
    |> Enum.map(fn blend_id ->
      IO.puts("Unlocking blend #{blend_id}")

      Blend.within(
        blend_id,
        fn ->
          Mix.Task.rerun("deps.unlock", args)
        end
      )
    end)
  end
end
