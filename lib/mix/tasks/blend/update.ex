defmodule Mix.Tasks.Blend.Update do
  use Mix.Task

  @shortdoc "Updates lockfiles from blend.exs"
  @requirements ["app.config"]

  @impl true
  def run(args) do
    Blend.blends()
    |> Enum.map(fn {blend_id, _deps} ->
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
