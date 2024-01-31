defmodule Juggler do
  require Logger

  @juggler_dir "juggler"
  @juggles_file_path "juggles.exs"
  @juggles_template """
  # Example for testing against 1.x and 2.x of some dependency
  # %{
  #   "dep-name-1-0": [{:dep_name, "~> 1.0"}],
  #   "dep-name-2-0": [{:dep_name, "~> 2.0"}],
  # }
  """

  def init do
    case File.read(@juggles_file_path) do
      {:ok, _} ->
        Logger.info("#{@juggles_file_path} file already exists, doing nothing")

      {:error, :enoent} ->
        File.write(@juggles_file_path, @juggles_template)
        Logger.info("Successfully created #{@juggles_file_path} file")
    end
  end

  def juggles do
    case File.read(@juggles_file_path) do
      {:ok, contents} ->
        case Code.eval_string(contents) do
          {%{} = map, _} ->
            map

          _ ->
            raise "Couldn't find a map defining your juggles in #{@juggles_file_path} file"
        end

      {:error, :enoent} ->
        raise "Couldn't find a #{@juggles_file_path} file"
    end
  end

  def within(juggle_id, fun) do
    with_project(juggle_id, juggle_deps(juggle_id), fun)
  end

  defp juggle_deps(juggle_id) do
    juggles() |> Map.fetch!(juggle_id)
  end

  defmodule TempApp do
    def project do
      Process.get(:project)
    end
  end

  defp with_project(name, deps, fun) do
    Process.put(
      :project,
      Mix.Project.config()
      |> Keyword.merge(
        app: name,
        deps:
          deps
          |> Enum.reduce(
            Mix.Project.config()[:deps],
            fn dep, acc ->
              acc
              |> List.keystore(elem(dep, 0), 0, dep)
            end
          ),
        lockfile: "#{@juggler_dir}/#{name}.mix.lock",
        build_path: "#{@juggler_dir}/_build/#{name}",
        deps_path: "#{@juggler_dir}/deps/#{name}"
      )
    )

    :ok = Mix.Project.push(TempApp)

    fun.()
  after
    Mix.Project.pop()
  end
end
