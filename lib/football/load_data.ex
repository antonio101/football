defmodule Football.LoadData do
  @moduledoc """
    This module read the data inside a CSV file and save this data in a ETS.
  """
  @csv_location Application.get_env(:football, :csv_location)
  @ets_name :football_matches
  

  defmodule State do
    @moduledoc """
      Here, we will store all data that we need during the execution of this script.
    """
    defstruct [
      :csv_content,
      :matches_data
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

  @spec init(list) :: tuple
  def init(opts) do

    State

    # Add the options to the state
    |> struct(opts)

    # Check if CSV file exists
    |> csv_exists()

    # Load content from CSV file
    |> load_csv_content()

    # Format the obtained content
    |> parse_content()

    # Save this content inside an ETS
    |> dump_content_to_ets()

    # Return the results
    |> return_result()
  end

  # Check if CSV file exists
  defp csv_exists(%State{} = state) do
    if !File.exists?(@csv_location) do
      %Error{reason: "Unable to read CSV file.", state: state}
    end
    
    state
  end

  # Read CSV file and get its content
  defp load_csv_content(%State{} = state) do
    csv_content = 
      @csv_location
      |> Path.expand
      |> File.stream!
      |> CSV.decode(separator: ?,, headers: true)
      
    %State{state | csv_content: csv_content}
  end
  defp load_csv_content(%Error{} = error), do: error

  # Parse getted content to a friendly readable content
  defp parse_content(%State{} = state) do
    %State{state | matches_data: csv_content_to_list(state.csv_content)}
  end
  defp parse_content(%Error{} = error), do: error

  # Function that parses the getted content to a friendly readable content
  defp csv_content_to_list(csv_content) do
      Enum.map(csv_content, fn full_row ->
        case full_row do
          {:ok, row_data} ->
            {row_data[""], row_data}
          _error ->
            :error
        end
      end)
  end

  # Save the content to an ETS
  defp dump_content_to_ets(%State{} = state) do
    :ets.new(@ets_name, [:set, :protected, :named_table])
    :ets.insert(@ets_name, state.matches_data)

    state
  end
  defp dump_content_to_ets(%Error{} = error), do: error

  @spec return_result(%State{} | %Error{}) :: atom | tuple
  # Return result (success)
  defp return_result(%State{} = state) do
    :ok
  end
  # Return result (fail)
  defp return_result(%Error{} = error) do
    {:error, error.reason}
  end

end