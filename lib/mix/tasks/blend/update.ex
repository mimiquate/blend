defmodule Mix.Tasks.Blend.Update do
  use Mix.Task

  @shortdoc "Updates lockfiles from blend.exs"
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
