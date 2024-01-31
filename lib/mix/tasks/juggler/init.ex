defmodule Mix.Tasks.Juggler.Init do
  use Mix.Task

  @shortdoc "Initializes an empty juggles.exs file"

  @impl true
  def run(_args) do
    Juggler.init()
  end
end
