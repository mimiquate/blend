defmodule Blend do
  @moduledoc """
  Documentation for `Blend`.
  """

  @blend_dir "blend"
  @blendfile_path "blend.exs"
  @blendfile_template File.read!(Path.join(__DIR__, "blend/templates/blend.exs"))

  def init do
    case File.read(@blendfile_path) do
      {:ok, _} ->
        IO.puts("#{@blendfile_path} file already exists, doing nothing")

      {:error, :enoent} ->
        File.write!(@blendfile_path, @blendfile_template)
        IO.puts("Successfully created #{@blendfile_path} file")
    end
  end

  def within(blend_id, fun) do
    with_project(blend_id, blend_deps(blend_id), fun)
  end

  def blends do
    case File.read(@blendfile_path) do
      {:ok, contents} ->
        case Code.eval_string(contents) do
          {%{} = map, _} ->
            map

          _ ->
            raise "Couldn't find a map defining your blends in #{@blendfile_path} file"
        end

      {:error, :enoent} ->
        raise "Couldn't find a #{@blendfile_path} file"
    end
  end

  defp blend_deps(blend_id) do
    blends() |> Map.fetch!(blend_id)
  end

  defp with_project(blend_id, deps, fun) do
    :ok =
      Mix.ProjectStack.push(
        Blend.TmpProject,
        Mix.Project.config()
        |> Keyword.merge(
          deps:
            deps
            |> Enum.reduce(
              Mix.Project.config()[:deps],
              fn dep, acc ->
                acc
                |> List.keystore(elem(dep, 0), 0, dep)
              end
            ),
          lockfile: "#{@blend_dir}/#{blend_id}.mix.lock",
          build_path: "#{@blend_dir}/_build/#{blend_id}",
          deps_path: "#{@blend_dir}/deps/#{blend_id}"
        ),
        "nofile"
      )

    fun.()
  after
    Mix.ProjectStack.pop()
  end
end
