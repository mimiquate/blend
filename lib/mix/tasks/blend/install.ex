defmodule Mix.Tasks.Blend.Install do
  @shortdoc "Initializes an empty blend.exs file"

  @moduledoc """
  A task to generates an empty blend.exs file for you
  to define your blends, if you don't yet have one.

  It is created with a commented example in it.

  ```
  $ mix blend.install
  Successfully created blend.exs file
  ```
  """

  use Mix.Task

  @impl true
  def run(_args) do
    Blend.install()
  end
end
