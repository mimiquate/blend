defmodule BlendTest do
  use ExUnit.Case
  doctest Blend

  @tmp_path Path.expand("../tmp", __DIR__)

  setup do
    File.mkdir_p!(@tmp_path)
    on_exit(fn -> File.rm_rf(@tmp_path) end)
    :ok
  end

  test "init/0 generates blend file" do
    File.cd!(
      @tmp_path,
      fn ->
        refute File.exists?("blend.exs")
        Mix.Task.run("blend.init")
        assert File.exists?("blend.exs")
      end
    )
  end

  test "blend.get task" do
    File.cd!(
      @tmp_path,
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
