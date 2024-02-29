defmodule Mix.Tasks.Blend.Clean do
  use Mix.Task

  @shortdoc "Cleans blend build artifacts"
  @requirements ["app.config"]

  @impl true
  def run(args) do
    Blend.clean_lockfiles()

    Blend.blends()
    |> Map.keys()
    |> Enum.map(fn blend_name ->
      IO.puts("Cleaning blend #{blend_name}")

      Blend.within(
        blend_name,
        fn ->
          Mix.Task.rerun("clean", ["--deps" | args])
        end
      )
    end)
  end
end
