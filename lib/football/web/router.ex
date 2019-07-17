alias Football.Web.PairsController
alias Football.Web.LeaguesController

defmodule Football.Web.Router do
  @moduledoc """
    This module will call the right module depending on the called URL.
  """
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  # List the league and season pairs
  get "/pairs" do
    PairsController.init(conn)
  end

  # Fetch the results for a specific league and season pair
  get "/leagues" do
    LeaguesController.init(conn)
  end

  # The rest of request aren't valid
  match _ do
    send_resp(conn, 404, "Request not found.")
  end
end
