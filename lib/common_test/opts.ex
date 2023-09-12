defmodule CommonTest.Opts do

  def parse(opts) do
    keep_opts = keep_opts([], ct_opts())
    opts
    |> OptionParser.parse(strict: ct_opts())
    |> normalize(keep_opts)
  end

  defp normalize({opts, _, _}, keep_opts) do
    opts = for {optkey, _} <- ct_opts() do
      case Keyword.get_values(opts, optkey) do
        [] -> default(optkey)
        res ->
          case optkey in keep_opts do
            true -> [{optkey, res}]
            false -> [{optkey, List.last(res)}]
          end

      end
    end
    |> List.flatten()

    for opt <- opts do
      map_to_ct_opt(opt, keep_opts)
    end

  end

  defp default(:dir), do: [{:dir, ["common_test"]}]
  defp default(:abort_if_missing_suites), do: [{:abort_if_missing_suites, true}]
  defp default(:logdir), do: {:logdir, "./results"}
  defp default(_), do: []

  defp keep_opts(keepopts, []), do: keepopts
  defp keep_opts(keepopts, [{opt, [_, :keep]} | rest]), do: keep_opts([opt | keepopts], rest)
  defp keep_opts(keepopts, [_ | rest]), do: keep_opts(keepopts, rest)

  defp map_to_ct_opt({:hook, val}, keep_opts), do: {:ct_hooks, Enum.map(val, &str_to_elixir_atom/1)}
  defp map_to_ct_opt({optkey, val}, keep_opts), do: {map_opt_key(optkey, keep_opts), map_opt_val(val)}

  defp str_to_elixir_atom(str), do: String.to_existing_atom("Elixir." <> str)

  defp map_opt_val(val) when is_binary(val), do: String.to_charlist(val)
  defp map_opt_val(val) when is_list(val), do: Enum.map(val, &String.to_charlist/1)
  defp map_opt_val(val), do: val

  defp map_opt_key(optkey, keep_opts) do
    case optkey in keep_opts do
      true -> String.to_atom(Atom.to_string(optkey) <> "s")
      false -> optkey
    end
  end

  def help() do
    help = for {optkey, _} <- ct_opts(), do: {optkey, help(optkey)}
    help
    |> Enum.filter(fn({_, h}) -> h != nil end)
    |> Enum.map(fn({optkey, h}) -> "#{optkey}: #{h}" end)
    |> Enum.join( "\n")
  end

  defp ct_opts() do
    [
      {:dir, [:string, :keep]}, # comma-separated list
      {:suite, [:string, :keep]}, # comma-separated list
      {:group, [:string, :keep]}, # comma-separated list
      {:testcase, [:string, :keep]}, # comma-separated list
      {:label, :string}, # String
      {:config, [:string, :keep]}, # comma-separated list
      {:spec, [:string, :keep]}, # comma-separated list
      {:join_specs, :boolean},
      {:allow_user_terms, :boolean}, # Bool
      {:logdir, :string}, # dir
      {:logopts, [:string, :keep]}, # comma-separated list
      {:verbosity, :integer}, # Integer
      {:cover, :boolean},
      {:cover_export_name, :string},
      {:repeat, :integer}, # integer
      {:duration, :string}, # format: HHMMSS
      {:until, :string}, # format: YYMoMoDD[HHMMSS]
      {:force_stop, :string}, # String
      {:basic_html, :boolean}, # Boolean
      {:stylesheet, :string}, # String
      {:decrypt_key, :string}, # String
      {:decrypt_file, :string}, # String
      {:abort_if_missing_suites, :boolean}, # Boolean
      {:multiply_timetraps, :integer}, # Integer
      {:scale_timetraps, :boolean},
      {:create_priv_dir, :string},
      {:include, :string},
      {:readable, :string},
      {:verbose, :boolean},
      {:name, :string},
      {:sname, :string},
      {:setcookie, :string},
      {:sys_config, [:string, :keep]}, # comma-separated list
      {:compile_only, :boolean},
      {:retry, :boolean},
      {:fail_fast, :boolean},
      {:hook, [:string, :keep]}
    ]
  end

  #defp help(:compile_only), do: "Compile modules in the project with the test configuration but do not run the tests"
  defp help(:dir), do: "List of additional directories containing test suites"
  defp help(:suite), do: "List of test suites to run"
  defp help(:group), do: "List of test groups to run"
  defp help(:testcase), do: "List of test cases to run"
  #defp help(:label), do: "Test label"
  defp help(:config), do: "List of config files"
  defp help(:spec), do: "List of test specifications"
  #defp help(:join_specs), do: "Merge all test specifications and perform a single test run"
  #defp help(:sys_config), do: "List of application config files"
  #defp help(:allow_user_terms), do: "Allow user defined config values in config files"
  #defp help(:logdir), do: "Log folder"
  #defp help(:logopts), do: "Options for common test logging"
  #defp help(:verbosity), do: "Verbosity"
  #defp help(:cover), do: "Generate cover data"
  #defp help(:cover_export_name), do: "Base name of the coverdata file to write"
  #defp help(:repeat), do: "How often to repeat tests"
  #defp help(:duration), do: "Max runtime (format: HHMMSS)"
  #defp help(:until), do: "Run until (format: HHMMSS)"
  #defp help(:force_stop), do: "Force stop on test timeout (true | false | skip_rest)"
  #defp help(:basic_html), do: "Show basic HTML"
  #defp help(:stylesheet), do: "CSS stylesheet to apply to html output"
  #defp help(:decrypt_key), do: "Path to key for decrypting config"
  #defp help(:decrypt_file), do: "Path to file containing key for decrypting config"
  defp help(:abort_if_missing_suites), do: "Abort if suites are missing"
  #defp help(:multiply_timetraps), do: "Multiply timetraps"
  #defp help(:scale_timetraps), do: "Scale timetraps"
  #defp help(:create_priv_dir), do: "Create priv dir (auto_per_run | auto_per_tc | manual_per_tc)"
  #defp help(:include), do: "Directories containing additional include files"
  #defp help(:readable), do: "Shows test case names and only displays logs to shell on failures (true | compact | false)"
  #defp help(:verbose), do: "Verbose output"
  #defp help(:name), do: "Gives a long name to the node"
  #defp help(:sname), do: "Gives a short name to the node"
  #defp help(:setcookie), do: "Sets the cookie if the node is distributed"
  #defp help(:retry), do: "Experimental feature. If any specification for previously failing test is found, runs them."
  #defp help(:fail_fast), do: "Experimental feature. If any test fails, the run is aborted. Since common test does not support this natively, we abort the rebar3 run on a failure. This may break CT's disk logging and other rebar3 features."
  #defp help(:hook), do: "Add hook in order from first to last to run before and after each test"
  defp help(_), do: :nil
























end
