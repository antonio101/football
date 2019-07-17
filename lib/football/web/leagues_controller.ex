defmodule Football.Web.LeaguesController do
  @moduledoc """
    This module returns a list (in JSON) of results for a specified division and
    season in the query string in the URL. All data about all matches is stored
    in an ETS.
  """
  @ets_name :football_matches

  import Plug.Conn

  defmodule State do
    @moduledoc """
      Here, we will store all data that we need during the execution of this script.
    """
    defstruct [
      :conn,         # Connection
      :params,       # We will save only the parameters that we need from the URL 
      :matches_data, # Matches data with all data
      :matches,      # Matches data with only the data that we want
    ]
  end

  defmodule Error do
    @moduledoc """
      We will return it if an error happens. In that case, we can know the
      reason (text message) and the state in that moment.
    """
    defstruct ~w(
      state
      reason
    )a
  end

  def init(conn) do
    %State{conn: conn}

    # Get all parameters that we need from the query string in the URL
    |> get_params_from_url()

    # Retrieve the matches' content from an ETS table that match with the parameters
    |> get_data_that_matches_from_ets()

    # Generate a list with the data that we want show
    |> format_obtained_content()

    # Show the result
    |> send_respond()
  end

  # Get all parameters that we need from the query string in the URL
  defp get_params_from_url(%State{conn: conn} = state) do

    params =
      conn.query_string
      |> URI.decode_query()
    
    params_we_want = %{
      "div"    => params["div"],
      "season" => params["season"]
    }
    
    %State{state | params: params_we_want}
  end

  # Retrieve the matches' content from an ETS table that match with the parameters
  defp get_data_that_matches_from_ets(%State{params: %{"div" => div, "season" => season}} = state) 
  when is_binary(div) and byte_size(div) > 0 and is_binary(season) and byte_size(season) > 0 do

    matches_data = :ets.match_object(@ets_name, {
      :"_", %{
        "Div"    => div,
        "Season" => season
      }
    })
    
    %State{state | matches_data: matches_data}
  end

  # If we arrive here, it means that we haven't recived the parameters
  defp get_data_that_matches_from_ets(%State{} = state) do
    %Error{reason: "Parameters not found.", state: state}
  end

  # We have all matches' data, but we don't need to show all data
  defp format_obtained_content(%State{matches_data: matches_data} = state) do
    
    matches = 
      # Loopping the matches
      Enum.reduce(matches_data, [], fn {_key, match}, acc ->

        # Match data only with de info that we need
        formatted_match = %{
          "AwayTeam" => match["AwayTeam"],
          "Date" => match["Date"],
          "FTAG" => match["FTAG"],
          "FTHG" => match["FTHG"],
          "FTR" => match["FTR"],
          "HTAG" => match["HTAG"],
          "HTHG" => match["HTHG"],
          "HTR" => match["HTR"],
          "HomeTeam" => match["HomeTeam"]
        }

        acc ++ [formatted_match]
      end)

    %State{state | matches: matches}

  end
  defp format_obtained_content(%Error{} = error), do: error

  # Show a HTTP response with a JSON body
  defp send_respond(%State{conn: conn, matches: matches}) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, Jason.encode!(matches))
  end

  # If an error has occurred, we will show it
  defp send_respond(%Error{state: state} = error) do
    state.conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, Jason.encode!(%{"error" => error.reason}))
  end
end
