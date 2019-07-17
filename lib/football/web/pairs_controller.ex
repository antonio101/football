defmodule Football.Web.PairsController do
  @moduledoc """
    This module read the data about all matches in ETS and returns a list (in JSON) with
    all the divisions that exist in this data and the same for their seasons.
  """
  @ets_name :football_matches

  import Plug.Conn

  defmodule State do
    @moduledoc """
      Here, we will store all data that we need during the execution of this script.
    """
    defstruct [
      :conn,           # Connection
      :matches_data,   # We will save here the raw content from the ETS
      :div_and_seasons # Divisions + its seasons that we have to show
    ]
  end

  def init(conn) do
    %State{conn: conn}

    # Get all the content stored in the ETS
    |> get_data_from_ets()

    # Generate a list of divisions + its available seasons with the getted content
    |> find_divs_and_seasons()

    # Show the result
    |> send_respond()
  end

  # Retrieve all matches' content from an ETS table
  def get_data_from_ets(%State{} = state) do
    matches_data = get_ets_data(@ets_name) 
    %State{state | matches_data: matches_data}
  end
 
  # We will get a list of seasons and their divisions inside. We will return a list of name + division + their name
  defp find_divs_and_seasons(%State{} = state) do

    # Getting data obainted previously from an ETS
    divs_with_seasons = find_divs_with_seasons(state.matches_data)

    all_divs_and_seasons = 

      # Loopping all divisions and their seasons inside
      Enum.reduce(divs_with_seasons, [], fn {div, seasons}, acc ->
        
        div_and_seasons = 

          # Loopping all seasons inside a division
          Enum.reduce(seasons, [], fn season, acc2 ->
            
            # We generate its name
            name = div_name(div) <> " " <> div_years(season)

            # Structure and content for each element from the result list
            acc2 ++ [%{
              "name"   => name,
              "div"    => div,
              "season" => season
            }]
          end)
        acc ++ div_and_seasons
      end)

    %State{state | div_and_seasons: all_divs_and_seasons}
  end

  # From all data obtained in CSV file, we will get a list of seasons and divisions
  defp find_divs_with_seasons(matches_data) do
    
    Enum.reduce(matches_data, %{}, fn {_key, %{"Div" => div, "Season" => season}}, acc ->

      # If the map contains this division
      if Map.has_key?(acc, div) do
        div_seasons = Map.get(acc, div) # Seasons stored until now for this division

        # If this season exists
        if Enum.member?(div_seasons, season) do
          acc
        else
          # If the season doen't exist for this division, we add it
          Map.put(acc, div, div_seasons ++ [season])
        end

      else
        # If the map doen't contains this division, we add it + the season of this loop
        Map.put_new(acc, div, [season])
      end
    end)
  end

  # Retrieve all content from an ETS table
  defp get_ets_data(table_name) do
    :ets.foldl(fn data, acc ->
      [data | acc]
    end, [], table_name)
  end

  # Returns name of division depending on its key
  defp div_name(key) do
    div_names = %{
      "D1"  => "Bundesliga",
      "E0"  => "Premier League",
      "SP1" => "La Liga Santander",
      "SP2" => "La Liga 123",
    }
    div_names[key]
  end

  # Transform "compressed" season (Example: "201718") to 2 years format (Example: "2017-2018")
  # Notice: 90s not considered
  defp div_years(season) do
    String.slice(season, 0, 4) <> "-" <> "20" <> String.slice(season, 4, 2)
  end

  # Show a HTTP response with a JSON body
  defp send_respond(%State{conn: conn, div_and_seasons: div_and_seasons}) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, Jason.encode!(div_and_seasons))
  end
end
