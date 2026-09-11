defmodule Blend.CLI do
  @moduledoc false
  # inspired by Mix.CLI https://github.com/elixir-lang/elixir/blob/v1.18.3/lib/mix/lib/mix/cli.ex

  @switches [
    blend: :string,
    deps: :string
  ]

  @doc """
  Runs Mix in the requested blend according to the command line arguments.

  Should be used internally by `mix blend ...` or `blend` escript.
  See `Mix.Tasks.Blend` for details.
  """
  def main(args \\ System.argv()) do
    if env_variable_activated?("MIX_DEBUG") do
      IO.puts("-> Running blend CLI #{inspect(args)}")
      {time, res} = :timer.tc(&main/2, [args, true])
      IO.puts(["<- Ran blend CLI in ", Integer.to_string(div(time, 1000)), "ms"])
      res
    else
      main(args, false)
    end
  end

  defp main(opts_and_args, debug?) do
    Mix.start()

    if debug?, do: Mix.debug(true)

    {opts, args} = OptionParser.parse_head!(opts_and_args, strict: @switches)
    load_mix_exs(args)
    project = Mix.Project.get()
    {task, task_args} = get_task(args, project)
    patch_and_reload_project(task, opts)
    run_task(task, task_args)
  end

  defp load_mix_exs(args) do
    file = System.get_env("MIX_EXS") || "mix.exs"

    if File.regular?(file) do
      Mix.ProjectStack.post_config(state_loader: {:cli, List.first(args)})
      Code.compile_file(file)
    end
  end

  defp get_task(["-" <> _ | _], project) do
    task = "mix blend #{default_task(project)}"

    Mix.shell().error(
      "** (Blend) Blend requires a task, none given.\n" <>
        "You need to invoke a task, such as #{inspect(task)}"
    )

    exit({:shutdown, 1})
  end

  defp get_task([h | t], _project) do
    {h, t}
  end

  defp get_task([], project) do
    {default_task(project), []}
  end

  defp default_task(project) do
    if function_exported?(project, :cli, 0) do
      project.cli()[:default_task] || "run"
    else
      Mix.Project.config()[:default_task] || "run"
    end
  end

  defp run_task(name, args) do
    try do
      # We must go through the task instead of invoking the
      # module directly because projects like Nerves alias it.
      Mix.Task.run("loadconfig")
      Mix.Task.run(name, args)
    rescue
      # We only rescue exceptions in the Mix namespace,
      # all others pass through and raise as usual.
      exception ->
        case {Mix.debug?(), Map.get(exception, :mix, false)} do
          {false, true} ->
            simplified_exception(exception, 1)

          {false, code} when code in 0..255 ->
            simplified_exception(exception, code)

          _ ->
            reraise exception, __STACKTRACE__
        end
    end
  end

  defp simplified_exception(%name{} = exception, code) do
    mod = name |> Module.split() |> hd()
    Mix.shell().error("** (#{mod}) #{Exception.message(exception)}")
    exit({:shutdown, code})
  end

  defp env_variable_activated?(name) do
    System.get_env(name) in ~w(1 true)
  end

  defp patch_and_reload_project(task, opts) do
    blend_id = Keyword.fetch!(opts, :blend)
    blend_deps = Keyword.fetch!(opts, :deps) |> parse_deps()

    if original_project = Mix.Project.pop() do
      fun_ast =
        for {name, arity} <- original_project.name.__info__(:functions), name != :project do
          args = Enum.map(1..arity//1, &Macro.var(:"arg#{&1}", nil))

          quote do
            defdelegate unquote(name)(unquote_splicing(args)), to: @original_project
          end
        end

      contents =
        quote do
          @blend_id unquote(blend_id)
          @blend_deps unquote(Macro.escape(blend_deps))
          @original_project unquote(original_project.name)
          def project do
            Blend.CLI.patch_project(@original_project.project(), @blend_id, @blend_deps)
          end

          unquote(fun_ast)
        end

      {:module, new_project, _, _} =
        Module.create(:"Blend.#{blend_id}", contents, Macro.Env.location(__ENV__))

      Mix.ProjectStack.post_config(state_loader: {:cli, task})
      Mix.Project.push(new_project, blend_id)
    end
  end

  @blend_dir "blend"
  def patch_project(config, blend_id, blend_deps) do
    old_deps = config[:deps] |> List.keydelete(:blend, 0)

    Keyword.merge(config,
      deps:
        Enum.reduce(blend_deps, old_deps, fn dep, acc ->
          List.keystore(acc, elem(dep, 0), 0, dep)
        end),
      lockfile: "#{@blend_dir}/#{blend_id}/mix.lock",
      build_path: "#{@blend_dir}/#{blend_id}/_build",
      deps_path: "#{@blend_dir}/#{blend_id}/deps"
    )
  end

  def parse_deps(binary) when is_binary(binary) do
    binary
    |> Code.string_to_quoted!()
    |> parse_deps([])
  end

  defp parse_deps([], acc), do: Enum.reverse(acc)

  defp parse_deps([term | rest], acc) do
    parse_deps(rest, parse_deps(term, acc))
  end

  defp parse_deps({:{}, _meta, value}, acc) do
    [List.to_tuple(value) | acc]
  end

  defp parse_deps({_, _} = term, acc) do
    [term | acc]
  end
end

# If stdin closes, we shutdown the VM,
# see: https://hexdocs.pm/elixir/Port.html#module-zombie-operating-system-processes
spawn(fn ->
  _ = IO.gets("")
  System.halt(0)
end)

Blend.CLI.main()
