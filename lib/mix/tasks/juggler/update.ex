defmodule Mix.Tasks.Juggler.Update do
  use Mix.Task

  @shortdoc "Updates lockfiles from juggles.exs"

  @impl true
  def run(args) do
    Juggler.juggles()
    |> Enum.map(fn {juggle_id, _deps} ->
      Juggler.within(
        juggle_id,
        fn ->
          Mix.Task.rerun("deps.update", args)
        end
      )
    end)
  end
end
