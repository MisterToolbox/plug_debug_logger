defmodule PlugDebugLoggerTest do
  use ExUnit.Case
  use Plug.Test
  doctest PlugDebugLogger
  import ExUnit.CaptureLog
  require Logger

  defmodule AllPlug do
    use Plug.Builder

    plug PlugDebugLogger
    plug :passthrough

    defp passthrough(conn, _), do: Plug.Conn.send_resp(conn, 200, "Passthrough")
  end

  defmodule AllInfoPlug do
    use Plug.Builder

    plug PlugDebugLogger, level: :info
    plug :passthrough

    defp passthrough(conn, _), do: Plug.Conn.send_resp(conn, 200, "Passthrough")
  end


  defmodule AtomOnlyPlug do
    use Plug.Builder

    plug PlugDebugLogger, only: :req_headers
    plug :passthrough

    defp passthrough(conn, _), do: Plug.Conn.send_resp(conn, 200, "Passthrough")
  end

  defmodule ListOnlyPlug do
    use Plug.Builder

    plug PlugDebugLogger, only: [:req_headers, :resp_headers]
    plug :passthrough

    defp passthrough(conn, _), do: Plug.Conn.send_resp(conn, 200, "Passthrough")
  end

  defmodule AtomExceptPlug do
    use Plug.Builder

    plug PlugDebugLogger, except: :req_headers
    plug :passthrough

    defp passthrough(conn, _), do: Plug.Conn.send_resp(conn, 200, "Passthrough")
  end

  defmodule ListExceptPlug do
    use Plug.Builder

    plug PlugDebugLogger, except: [:req_headers, :resp_headers]
    plug :passthrough

    defp passthrough(conn, _), do: Plug.Conn.send_resp(conn, 200, "Passthrough")
  end

  test "default config logs debug level to console" do
    [_, message | _rest] = capture_log_lines(fn ->
        AllPlug.call(conn(:get, "/"), [])
      end)
    assert message =~ ~r"\[debug\]"u
  end

  test "logs configured level to console" do
    [_, message | _rest] = capture_log_lines(fn ->
        AllInfoPlug.call(conn(:get, "/"), [])
      end)
    assert message =~ ~r"\[info\]"u
  end

  test ":only with a single atom logs only that key from the Plug.Conn" do
    [_, _,  message | _rest] = capture_log_lines(fn ->
        AtomOnlyPlug.call(conn(:get, "/"), [])
      end)
    assert message =~ ~r"req_headers"u
  end

  test ":only with a list of atoms logs only those keys from the Plug.Conn" do
    [_, _,  _, req_message, resp_message | _rest] = capture_log_lines(fn ->
        ListOnlyPlug.call(conn(:get, "/"), [])
      end)
    assert req_message =~ ~r"req_headers"u
    assert resp_message =~ ~r"resp_headers"u
  end

  test ":except with a single atom logs a Plug.Conn without that key" do
    lines = capture_log_lines(fn ->
        AtomExceptPlug.call(conn(:get, "/"), [])
      end)
    Enum.each(lines, fn(line) -> refute line =~ ~r"req_headers"u end)
  end

  test ":except with a list of atoms logs a Plug.Conn without those keys" do
    lines = capture_log_lines(fn ->
        ListExceptPlug.call(conn(:get, "/"), [])
      end)
    Enum.each(lines, fn(line) ->
      refute line =~ ~r"req_headers"u
      refute line =~ ~r"resp_headers"u
    end)
  end

  defp capture_log_lines(fun) do
    fun
    |> capture_log()
    |> String.split("\n", trim: true)
  end
end
