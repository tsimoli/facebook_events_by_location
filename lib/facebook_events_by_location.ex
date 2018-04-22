defmodule FacebookEventsByLocation do
  alias FacebookEventsByLocation.Client

  @moduledoc """
  Documentation for FacebookEventsByLocation.
  """

  @doc """
  Get events by location.
  """
  def get_events_by_location(locations, opts \\ []) do
    Client.fetch_events_by_locations(locations, opts)
  end
end
