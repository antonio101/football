defmodule Football.Tests.PairsControllerTest do
  @moduledoc """
    We will verify that PairsController works correctly.
  """
  use ExUnit.Case
  use Plug.Test

  alias Football.Web.PairsController

  test "HTTP request to get available pairs" do
    conn = conn(:get, "/pairs")
    resp = PairsController.init(conn)
    decoded_resp = Jason.decode!(resp.resp_body)
    
    expected_resp = [
      %{"div" => "D1",  "name" => "Bundesliga 2016-2017",  "season" => "201617"},
      %{"div" => "E0",  "name" => "Premier League 2016-2017",  "season" => "201617"},
      %{"div" => "SP1", "name" => "La Liga Santander 2016-2017", "season" => "201617"},
      %{"div" => "SP1", "name" => "La Liga Santander 2015-2016", "season" => "201516"},
      %{"div" => "SP2", "name" => "La Liga 123 2015-2016", "season" => "201516"},
      %{"div" => "SP2", "name" => "La Liga 123 2016-2017", "season" => "201617"}
    ]

    assert decoded_resp == expected_resp
  end

  
end
