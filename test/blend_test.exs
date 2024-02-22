defmodule BlendTest do
  use ExUnit.Case
  doctest Blend

  @tag :tmp_dir
  test "init/0 generates blend file", %{tmp_dir: tmp_dir} do
    File.cd!(
      tmp_dir,
      fn ->
        refute File.exists?("blend.exs")
        Mix.Task.run("blend.init")
        assert File.exists?("blend.exs")
      end
    )
  end

  @tag :tmp_dir
  test "blend.get task", %{tmp_dir: tmp_dir} do
    File.cd!(
      tmp_dir,
      fn ->
        File.write(
          "blend.exs",
          """
          %{
            "jason-1-0": [{:jason, "~> 1.0"}]
          }
          """
        )

        Mix.Task.run("blend.get")
        File.exists?("blend/jason-1-0.mix.lock")
      end
    )

    assert true
  end
end
