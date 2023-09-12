defmodule Mix.Tasks.CommonTest do
  use Mix.Task

  def run(args) do


    Mix.Task.run(:loadpaths)

    ct_opts = CommonTest.Opts.parse(args) |> IO.inspect()

    paths = Keyword.get(ct_opts, :dirs)
    suites = Keyword.get(ct_opts, :suites, ["*_suite"])

    ct_opts = Keyword.drop(ct_opts, [:dirs, :suites])
    Application.put_env(:common_test, :auto_compile, false)

    modules = lookup_modules_from_suites(paths, suites)

    :ct.run_testspec([
      {:suites, paths, modules} | ct_opts
    ]|> IO.inspect())

  end

  defp lookup_modules_from_suites(paths, suites) do
    modules = for path <- paths do
      IO.inspect(path, label: PATH)

      for suite <- suites do
        match = Path.join([path, "**", "#{suite}.exs"])
        for file <- Path.wildcard(match),
            {module, _} <- Code.require_file(file),
            do: module
      end
    end |> List.flatten()
    |> IO.inspect
  end
end
