defmodule Mix.Tasks.CommonTest do
  require Logger
  use Mix.Task

  def run(args) do

    Mix.Task.run(:loadpaths)

    test_spec_opts = CommonTest.Opts.parse(args)

    dirs = Keyword.get(test_spec_opts, :dirs)
    suites = Keyword.get(test_spec_opts, :suites, ["*_suite"])
    configs = Keyword.get(test_spec_opts, :config, [])
    |> lookup_configs_from_suites(dirs, suites)

    test_spec_opts = Keyword.drop(test_spec_opts, [:dirs, :suites, :config])
    Application.put_env(:common_test, :auto_compile, false)

    suites_modules = lookup_modules_from_suites(dirs, suites)

    test_spec_opts = [{:suites, dirs, suites_modules} | test_spec_opts]

    ## Doesn't work with config: []
    test_spec_opts = case configs do
      [] -> test_spec_opts
      _ -> [{:config, configs} | test_spec_opts]
    end

    IO.inspect("Running testspec with opts #{inspect(test_spec_opts)}")

    :ct.run_testspec(test_spec_opts)

  end

  defp lookup_configs_from_suites([], paths, suites) do
    for path <- paths do
      for suite <- suites do
        match = Path.join([path, "#{suite}_data", "#{suite}.config"])
        Path.wildcard(match)
      end
    end |> List.flatten()
    |> Enum.map(fn(f) -> String.to_charlist(f) end)
  end
  defp lookup_configs_from_suites(explicit_configs, _, _), do: explicit_configs
  defp lookup_modules_from_suites(paths, suites) do
    for path <- paths do
      for suite <- suites do
        match = Path.join([path, "**", "#{suite}.exs"])
        for file <- Path.wildcard(match),
            {module, _} <- Code.require_file(file),
            do: module
      end
    end |> List.flatten()
  end
end
