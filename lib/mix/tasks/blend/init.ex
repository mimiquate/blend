defmodule Mix.Tasks.Blend.Init do
  @shortdoc "Initializes an empty blend.exs file"

  @moduledoc """
  A task to generates an empty blend.exs file for you
  to define your blends, if you don't yet have one.

  It is created with a commented example in it.

  ```
  $ mix blend.init
  Successfully created blend.exs file
  ```
  """

  use Mix.Task

  @impl true
  def run(_args) do
    Blend.init()
  end
end
