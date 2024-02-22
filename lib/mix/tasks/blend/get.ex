defmodule Mix.Tasks.Blend.Get do
  use Mix.Task

  @shortdoc "Generates lockfiles from blend.exs"
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
