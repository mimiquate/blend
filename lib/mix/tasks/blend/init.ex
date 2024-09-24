defmodule Mix.Tasks.Blend.Init do
  @moduledoc false

  use Mix.Task

  @impl true
  def run(_args) do
    Blend.install()
  end
end
