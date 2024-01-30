defmodule Juggler do
  @juggler_dir "juggler"
  @juggles_file_path "juggles.exs"

  def juggles do
    with {:ok, contents} <- File.read(@juggles_file_path),
         {%{} = contents, _} <- Code.eval_string(contents) do
      contents
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
      |> Keyword.merge([
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
      ])
    )

    :ok = Mix.Project.push(TempApp)

    fun.()
  after
    Mix.Project.pop()
  end
end
