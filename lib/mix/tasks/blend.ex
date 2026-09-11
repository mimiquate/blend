defmodule Mix.Tasks.Blend do
  use Mix.Task

  @shortdoc "Runs the given Mix task in the context of blend lockfile(s)"

  @moduledoc """
  Runs the given Mix task in the context of blend lockfile(s)

      $ mix blend cmd echo 'Hello from blend: $BLEND'
      Running Blend with: mix cmd echo 'Hello from blend: $BLEND'

      ==> 🥣 plug_crypto_1
      🥣 plug_crypto_1 | Hello from blend: plug_crypto_1
      🥣 plug_crypto_1 succeeded

      ==> 🥣 plug_crypto_2
      🥣 plug_crypto_2 | Hello from blend: plug_crypto_2
      🥣 plug_crypto_2 succeeded

  ## Command-line options

    * `--exclude` - excludes blends with the specified name. This option may be
     given several times to apply different filters, such as `--exclude blend1 --exclude blend2`
    * `--only` - runs only blends with the specified name. This option may be
     given several times to apply different filters, such as `--only blend1 --only blend2`
    * `--no-raise` - continues the execution of other blends, instead of immediately raising
     on the first failed blend
  """

  @app_version Mix.Project.config()[:version]
  @external_resource Path.join(:code.priv_dir(:blend), "cli.exs")
  @execute_script File.read!(@external_resource)
  @colors ~w[cyan yellow green magenta blue red light_cyan light_yellow light_green light_magenta light_blue light_red]a

  @switches [
    exclude: :keep,
    only: :keep,
    raise: :boolean
  ]

  @doc false
  def main(args), do: run(args, true)

  @impl true
  def run(args, escript? \\ false) do
    {opts, env_args, task_and_args} = parse_args(args)
    execute_script = execute_script_path(escript?)

    opts =
      opts
      |> filter_opts(:exclude)
      |> filter_opts(:only)
      |> normalize_opts()

    Mix.shell().info("Running Blend with: #{command_description(env_args, task_and_args)}")
    print_filters(opts, :exclude)
    print_filters(opts, :only)
    Mix.shell().info("")

    Blend.blends()
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.zip(@colors)
    |> Enum.filter(&(opts[:only] == [] or elem(elem(&1, 0), 0) in opts[:only]))
    |> Enum.reject(&(elem(elem(&1, 0), 0) in opts[:exclude]))
    |> run_blends(execute_script, env_args, task_and_args, opts)
    |> process_result(opts)
  end

  defp run_blends(blends, execute_script, env_args, task_and_args, opts) do
    blends
    |> Enum.reduce(-2, fn {{blend_id, blend_deps}, color}, last_exit_code ->
      Mix.shell().info("==> 🥣 #{IO.ANSI.format([color, to_string(blend_id)])}")
      exit_code = run_blend(blend_id, blend_deps, color, execute_script, env_args, task_and_args)

      cond do
        Keyword.get(opts, :raise, true) and exit_code != 0 ->
          Mix.raise("🥣 #{command_description(env_args, task_and_args, blend_id)} failed\n\n",
            exit_status: 1
          )

        exit_code != 0 ->
          Mix.shell().error(
            "🥣 #{command_description(env_args, task_and_args, blend_id)} failed with exit code #{exit_code}\n"
          )

        true ->
          Mix.shell().info(
            IO.ANSI.format([
              :green,
              "🥣 #{blend_id} succeeded\n"
            ])
          )
      end

      max(exit_code, last_exit_code)
    end)
  end

  defp process_result(exit_code, opts) do
    cond do
      exit_code == -2 and (opts[:excluded] != [] or opts[:only] != []) ->
        Mix.shell().info(IO.ANSI.format([:yellow, "\nAll blends have been excluded\n"]))

        if opts[:only] != [] do
          Mix.raise("The --only option was given to \"mix blend\" but no blend was mixed")
        end

      exit_code > 0 ->
        System.halt(exit_code)

      true ->
        :ok
    end
  end

  defp run_blend(blend_id, blend_deps, color, execute_script, env_args, task_and_args) do
    elixir = System.find_executable("elixir") || raise "cannot find elixir executable"
    env_vars = [{~c"BLEND", to_charlist(blend_id)} | env_args]
    prefix = ["🥣 ", IO.ANSI.format([color, to_string(blend_id)]), " | "]

    cmd_args =
      [
        if(IO.ANSI.enabled?(), do: ~c"--color", else: ~c"--no-color"),
        ~c"-r",
        execute_script,
        ~c"--",
        ~c"--blend",
        blend_id,
        ~c"--deps",
        encode_term(blend_deps),
        ~c"--"
        | task_and_args
      ]

    options = [
      :stream,
      :binary,
      :exit_status,
      :use_stdio,
      :stderr_to_stdout,
      env: env_vars,
      args: cmd_args
    ]

    port = Port.open({:spawn_executable, elixir}, options)

    stdin_pid = Process.spawn(__MODULE__, :forward_stdin, [port], [:link])
    print_stdout(port, stdin_pid, prefix)
  end

  @doc false
  def forward_stdin(port) do
    case IO.gets(:stdio, "") do
      :eof -> :ok
      {:error, reason} -> throw(reason)
      data -> Port.command(port, data)
    end
  end

  defp print_stdout(port, stdin_pid, prefix, print_prefix \\ true) do
    receive do
      {^port, {:data, data}} ->
        prefixed_lines = String.replace(data, ~r/\n(?!$)/, "\n#{prefix}")

        if print_prefix do
          IO.write(:stdio, "#{prefix}" <> prefixed_lines)
        else
          IO.write(:stdio, prefixed_lines)
        end

        print_stdout(port, stdin_pid, prefix, String.ends_with?(data, "\n"))

      {^port, {:exit_status, status}} ->
        Process.unlink(stdin_pid)
        Process.exit(stdin_pid, :kill)
        status
    end
  end

  defp encode_term(term) do
    term |> inspect() |> to_charlist()
  end

  defp parse_args(args) do
    {opts, env_task_and_args} = OptionParser.parse_head!(args, strict: @switches)

    {env_args, task_and_args} =
      Enum.split_while(env_task_and_args, fn x -> String.match?(x, ~r/^\w+=\w+$/) end)

    env =
      Enum.map(env_args, fn env_arg ->
        [name, value] = String.split(env_arg, "=")
        {String.to_charlist(name), String.to_charlist(value)}
      end)

    {opts, env, task_and_args}
  end

  defp execute_script_path(false), do: hd(@external_resource)

  defp execute_script_path(true) do
    tmp_dir = System.tmp_dir!() |> Path.expand()
    blend_tmp_dir = Path.join([tmp_dir, "blend", @app_version])
    File.mkdir_p!(blend_tmp_dir)
    path = Path.join([blend_tmp_dir, "cli.exs"])

    if not File.exists?(path) or @app_version =~ "-dev" do
      File.write!(path, @execute_script)
    end

    path
  end

  defp parse_filters(opts, key) do
    if Keyword.has_key?(opts, key) do
      Keyword.get_values(opts, key) |> Enum.map(&String.to_atom/1)
    end
  end

  defp filter_opts(opts, :only) do
    if filters = parse_filters(opts, :only) do
      opts
      |> Keyword.put(:only, filters)
      |> Keyword.put(:exclude, [])
    else
      opts
    end
  end

  defp filter_opts(opts, key) do
    if filters = parse_filters(opts, key) do
      Keyword.put(opts, key, filters)
    else
      opts
    end
  end

  defp normalize_opts(opts) do
    {only, exclude} = ExUnit.Filters.normalize(opts[:only], opts[:exclude])

    opts
    |> Keyword.put(:exclude, exclude)
    |> Keyword.put(:only, only)
  end

  defp print_filters(opts, key) do
    case opts[key] do
      [] -> :ok
      filters -> Mix.shell().info(format_filters(filters, key))
    end
  end

  defp format_filters(filters, type) do
    case type do
      :exclude -> "Excluding blends: #{inspect(filters, charlists: :as_lists)}"
      :only -> "Including blends: #{inspect(filters, charlists: :as_lists)}"
    end
  end

  defp command_description(env_args, task_and_args, blend_id \\ nil) do
    [
      Enum.map_join(env_args, " ", fn {k, v} -> "#{k}=#{v}" end),
      if(blend_id, do: "mix blend --only #{blend_id}", else: "mix"),
      Enum.map_join(task_and_args, " ", fn arg ->
        if String.contains?(arg, " ") do
          "'#{arg}'"
        else
          arg
        end
      end)
    ]
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(" ")
  end
end
