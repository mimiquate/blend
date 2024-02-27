maybe_put_env = fn varname, value ->
  System.put_env(varname, System.get_env(varname, value))
end

existing_blend = fn name ->
  Code.eval_file("blend.exs")
  |> elem(0)
  |> Map.fetch!(String.to_atom(name))
end

blend = System.get_env("BLEND")

if blend && String.length(blend) > 0 && existing_blend.(blend) do
  maybe_put_env.("MIX_LOCKFILE", "blend/#{blend}.mix.lock")
  maybe_put_env.("MIX_DEPS_PATH", "blend/deps/#{blend}")
  maybe_put_env.("MIX_BUILD_ROOT", "blend/_build/#{blend}")
end
