defmodule BlendTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  doctest Blend

  @tag :tmp_dir
  test "install/0 generates blend file", %{tmp_dir: tmp_dir} do
    File.cd!(
      tmp_dir,
      fn ->
        refute File.exists?("blend.exs")

        assert with_io(fn ->
                 Mix.Task.run("blend.install")
               end) == {:ok, "Successfully created blend.exs file\n"}

        assert File.exists?("blend.exs")
      end
    )
  end

  @tag :tmp_dir
  test "blend.clean", %{tmp_dir: tmp_dir} do
    File.cd!(
      tmp_dir,
      fn ->
        File.write(
          "blend.exs",
          """
          %{
            jason_1: [{:jason, "~> 1.0"}]
          }
          """
        )

        run("blend.get")
        assert File.exists?("blend/jason_1/mix.lock")

        File.write(
          "blend.exs",
          """
          %{
            plug_1: [{:plug, "~> 1.0"}]
          }
          """
        )

        run("blend.get")
        run("blend.clean")

        assert File.exists?("blend/plug_1/mix.lock")
        refute File.exists?("blend/jason_1/mix.lock")
      end
    )
  end

  defp run(args) do
    {:ok, _output} = with_io(fn -> Mix.Task.rerun(args) end)
  end
end
