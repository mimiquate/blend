defmodule Mix.Tasks.Blend.Clean do
  use Mix.Task

  @shortdoc "Cleans blend build artifacts"
  @requirements ["app.config"]

  @impl true
  def run(args) do
    Blend.blends()
    |> Map.keys()
    |> Enum.map(fn blend_id ->
      IO.puts("Cleaning blend #{blend_id}")

      Blend.within(
        blend_id,
        fn ->
          Mix.Task.rerun("clean", ["--deps" | args])
        end
      )
    end)
  end
end
