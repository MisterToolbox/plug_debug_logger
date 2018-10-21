# PlugDebugLogger

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

