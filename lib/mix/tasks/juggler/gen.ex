defmodule Mix.Tasks.Juggler.Gen do
  use Mix.Task

  @shortdoc "Generates lockfiles from juggles.exs"

  @impl true
  def run(_args) do
    Juggler.juggles()
    |> Enum.map(fn {juggle_id, _deps} ->
      Juggler.within(
        juggle_id,
        fn ->
          Mix.Task.rerun("deps.get")
        end
      )
    end)
  end
end
