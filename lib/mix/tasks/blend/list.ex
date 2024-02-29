defmodule Mix.Tasks.Blend.List do
  @shortdoc "Lists blend names defined in blend.exs file"

  @moduledoc """
  A task to list to quickly get a list of blend names you have defined in
  your blend.exs file.

  ```
  $ mix blend.list
  plug_crypto_1
  plug_crypto_2
  ```
  """

  use Mix.Task

  @impl true
  def run(_args) do
    Blend.blends()
    |> Map.keys()
    |> Enum.join("\n")
    |> IO.puts()
  end
end
