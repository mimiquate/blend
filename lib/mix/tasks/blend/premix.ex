defmodule Mix.Tasks.Blend.Premix do
  use Mix.Task

  @shortdoc "Generates premix.exs file"

  @impl true
  def run(_args) do
    Blend.premix()
  end
end
