defmodule Mix.Tasks.Blend.Premix do
  @shortdoc "Generates premix.exs file"

  @moduledoc """
  Task to generate the `premix.exs` file, which helps confuguring your
  package project to easily run any mix task against a specific blend
  lockfile.
  """

  use Mix.Task

  @impl true
  def run(_args) do
    Blend.premix()
  end
end
