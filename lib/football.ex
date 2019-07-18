alias Football.Web.Router
alias Plug.Cowboy
alias Football.LoadData

defmodule Football do
  @moduledoc false

  use Application

  def start(_type, _args) do
    LoadData.init([])

    children = [
      Cowboy.child_spec(
        scheme: :http,
        plug: Router,
        options: [port: 4001]
      )
    ]

    opts = [strategy: :one_for_one, name: Football.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
