defmodule Football.Tests.LeaguesControllerTest do
  @moduledoc """
    We will verify that LeaguesControllerTest works correctly.
  """
  use ExUnit.Case
  use Plug.Test

  alias Football.Web.LeaguesController

  test "HTTP request to get available results" do
    conn = conn(:get, "/leagues?div=SP1&season=201617")
    resp = LeaguesController.init(conn)
    decoded_resp = Jason.decode!(resp.resp_body)

    # We will use only the 1st part for checking
    [decoded_resp_first | _] = decoded_resp

    expected_resp = %{
      "AwayTeam" => "La Coruna",
      "Date"     => "05/03/2017",
      "FTAG"     => "1",
      "FTHG"     => "0",
      "FTR"      => "A",
      "HTAG"     => "1",
      "HTHG"     => "0",
      "HTR"      => "A",
      "HomeTeam" => "Sp Gijon"
    }

    assert decoded_resp_first == expected_resp
  end

end
