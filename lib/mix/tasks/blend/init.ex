defmodule Mix.Tasks.Blend.Init do
  use Mix.Task

  @shortdoc "Initializes an empty blend.exs file"

  @impl true
  def run(_args) do
    Blend.init()
  end
end
