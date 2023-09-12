defmodule Commoner.Hooks.Sample do
  require Logger

  def init(_id, _opts) do
    {:ok, nil}
  end

  def post_end_per_testcase(suite, testcase, config, :ok, state) do
    Logger.info("OK -> #{inspect({suite, testcase})}")
    {:ok, state}
  end

  def post_end_per_testcase(suite, testcase, config, return, state) do
    Logger.warning("ERROR -> #{inspect({suite, testcase})}")
    {return, state}
  end

  def on_tc_fail(suite, name, {%ExUnit.AssertionError{} = error, _}, state) do
    write(Exception.message(error))

    :ct.log(:error, 100, Exception.message(error))

    state
  end

  def on_tc_fail(_, _, _, state) do
    state
  end

  defp write(message), do: IO.write(:user, IO.ANSI.format(message))
end
