defmodule Mix.Tasks.Blend.Premix do
  @moduledoc false

  use Mix.Task

  @impl true
  def run(_args) do
    Blend.generate_premix()
  end
end
