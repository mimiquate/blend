defmodule JugglerTest do
  use ExUnit.Case
  doctest Juggler

  @tmp_path Path.expand("../tmp", __DIR__)

  setup do
    File.mkdir_p!(@tmp_path)
    on_exit(fn -> File.rm_rf(@tmp_path) end)
    :ok
  end

  test "init/0 generates juggles file" do
    File.cd!(
      @tmp_path,
      fn ->
        refute File.exists?("juggles.exs")
        assert Juggler.init() == :ok
        assert File.exists?("juggles.exs")
      end
    )
  end

  test "juggler.get task" do
    File.cd!(
      @tmp_path,
      fn ->
        File.write(
          "juggles.exs",
          """
          %{
            "jason-1-0": [{:jason, "~> 1.0"}]
          }
          """
        )
        Mix.Task.run("juggler.get")
        File.exists?("juggler/jason-1-0.mix.lock")
      end
    )

    assert true
  end
end
