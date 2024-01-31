defmodule Mix.Tasks.Juggler.Get do
  use Mix.Task

  @shortdoc "Generates lockfiles from juggles.exs"

  @impl true
  def run(args) do
    Juggler.juggles()
    |> Enum.map(fn {juggle_id, _deps} ->
      Juggler.within(
        juggle_id,
        fn ->
          Mix.Task.rerun("deps.get", args)
        end
      )
    end)
  end
end
