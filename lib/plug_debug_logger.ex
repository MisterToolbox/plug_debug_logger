defmodule PlugDebugLogger do
  @moduledoc """
  A plug for logging Plug.Conn debug information.

  To use it, plug it into the desired module.

      plug PlugDebugLogger, level: :debug
      plug PlugDebugLogger, level: :debug, only: :req_headers
      plug PlugDebugLogger, level: :debug, only: [:req_headers, :resp_headers]
      plug PlugDebugLogger, level: :debug, except: :req_headers
      plug PlugDebugLogger, level: :debug, except: [:req_headers, :resp_headers]

  ## Options

    * `:level`  - The log level at which to log its Plug.Conn info (Default is `:debug`)
    * `:only`   - The Plug.Conn key(s) to include in debug logging (atom or list of atoms)
    * `:except` - The Plug.Conn key(s) to exclude from debug logging (atom or list of atoms)
  """

  require Logger
  @behaviour Plug

  def init(opts) do
    %{
      except: Keyword.get(opts, :except),
      level:  Keyword.get(opts, :level, :debug),
      only:   Keyword.get(opts, :only)
    }
  end

  @doc "if neither `only` nor `except` are specified, log the entire Plug.Conn struct"
  def call(conn, %{except: nil, level: level, only: nil}) do
    log_conn(conn, level)
    conn
  end

  @doc "log only the specified keys from the Plug.Conn struct"
  def call(conn, %{except: nil, level: level, only: only}) when is_list(only) do
    Map.take(conn, only)
    |> log_conn(level)
    conn
  end
  def call(conn, opts = %{except: nil, only: only}), do: call(conn, %{opts | only: [only]})

  @doc "prune :except keys from the Plug.Conn struct and log the remaining struct"
  def call(conn, %{except: except, level: level, only: nil}) when is_list(except) do
    Map.drop(conn, except)
    |> log_conn(level)
    conn
  end
  def call(conn, opts = %{except: except, only: nil}), do: call(conn, %{opts | except: [except]})

  #@doc "format the `Logger` output"
  defp log_conn(conn, level), do: Logger.log(level, "Plug.Conn Debug:\n" <> inspect(conn, pretty: true))
end
