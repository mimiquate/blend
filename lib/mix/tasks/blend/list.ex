defmodule Mix.Tasks.Blend.List do
  use Mix.Task

  @shortdoc "Lists blend names defined in blend.exs file"

  @impl true
  def run(_args) do
    Blend.blends()
    |> Map.keys()
    |> Enum.join("\n")
    |> IO.puts()
  end
end
