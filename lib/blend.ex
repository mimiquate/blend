defmodule Blend do
  @moduledoc false

  @blend_dir "blend"
  @blendfile_name "blend.exs"
  @blendfile_template File.read!(Path.join(__DIR__, "blend/templates/blend.exs"))
  @premix_file_name "premix.exs"
  @premix_file_template File.read!(Path.join(__DIR__, "blend/templates/premix.exs"))

  def install do
    case File.read(@blendfile_name) do
      {:ok, _} ->
        IO.puts("#{@blendfile_name} file already exists, doing nothing")

      {:error, :enoent} ->
        File.write!(@blendfile_name, @blendfile_template)
        IO.puts("Successfully created #{@blendfile_name} file")
    end
  end

  def generate_premix do
    path = Path.join(@blend_dir, @premix_file_name)

    File.mkdir_p!(@blend_dir)
    File.write!(path, @premix_file_template)

    IO.puts("Written #{path} file")
  end

  def within(blend_id, fun) do
    host_project_config = Mix.Project.config()

    :ok =
      Mix.ProjectStack.push(
        Blend.TmpProject,
        host_project_config
        |> Keyword.merge(
          deps:
            blends()
            |> Map.fetch!(blend_id)
            |> Enum.reduce(
              host_project_config[:deps],
              fn dep, acc ->
                acc
                |> List.keystore(elem(dep, 0), 0, dep)
              end
            ),
          lockfile: "#{@blend_dir}/#{blend_id}/mix.lock",
          build_path: "#{@blend_dir}/#{blend_id}/_build",
          deps_path: "#{@blend_dir}/#{blend_id}/deps"
        ),
        "nofile"
      )

    fun.()
  after
    Mix.ProjectStack.pop()
  end

  def blends do
    case File.read(@blendfile_name) do
      {:ok, contents} ->
        case Code.eval_string(contents) do
          {%{} = map, _} ->
            map

          _ ->
            raise "Couldn't find a map defining your blends in #{@blendfile_name} file"
        end

      {:error, :enoent} ->
        raise "Couldn't find a #{@blendfile_name} file"
    end
  end

  def clean_lockfiles do
    blend_names = blends() |> Map.keys()

    Path.wildcard("#{@blend_dir}/*/mix.lock")
    |> Enum.reject(fn path ->
      path in Enum.map(blend_names, fn name -> "#{@blend_dir}/#{name}/mix.lock" end)
    end)
    |> Enum.each(&File.rm!/1)
  end
end
