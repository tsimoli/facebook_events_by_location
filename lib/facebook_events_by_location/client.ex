defmodule FacebookEventsByLocation.Client do
  alias FacebookEventsByLocation.{UrlHelper, ResponseHelper, EventData}

  @http_options [connect_timeout: 5_000, recv_timeout: 5_000, timeout: 5_000]

  @doc """
  Fetches events by locations
  """
  def fetch_events_by_locations(locations, opts \\ [])

  def fetch_events_by_locations(locations, opts) when is_list(locations) do
    events =
      Enum.map(locations, &UrlHelper.create_place_url(&1, opts))
      |> Enum.map(&fetch_event_ids(&1))
      |> List.flatten()
      |> Enum.uniq()
      |> fetch_events

    {:ok, events}
  end

  def fetch_events_by_locations(_locations, _opts) do
    {:error, "Locations needs to be list"}
  end

  defp fetch_event_ids(url) do
    fetch_ids_paging(url, [])
  end

  defp fetch_ids_paging(url, ids) do
    parsed_response =
      HTTPoison.get!(url, [], @http_options)
      |> ResponseHelper.parse_response()

    case parsed_response do
      {:error, _msg} ->
        []

      _ ->
        eventIds = parsed_response["data"]
        next_url = get_in(parsed_response, ["paging", "next"])
        new_ids = Enum.map(eventIds, fn %{"id" => id} -> id end)

        case next_url do
          nil ->
            ids ++ new_ids

          _ ->
            fetch_ids_paging(next_url, ids ++ new_ids)
        end
    end
  end

  defp fetch_events(place_ids) do
    Enum.chunk_every(place_ids, 50, 50, [])
    |> Enum.map(fn chunk_of_ids ->
      Task.Supervisor.async(FacebookEventsByLocation.TaskSupervisor, fn ->
        fetch_event(UrlHelper.create_fetch_places_url(chunk_of_ids))
      end)
    end)
    |> Enum.map(&Task.await(&1, 10000))
  end

  defp fetch_event(url) do
    HTTPoison.get!(url, [], @http_options)
    |> ResponseHelper.parse_response()
    |> parse_events_from_response
  end

  defp parse_events_from_response({:error, _}) do
    []
  end

  defp parse_events_from_response(places) do
    places
    |> Map.keys()
    |> Enum.map(&places[&1])
    |> Enum.map(&parse_place(&1))
    |> List.flatten()
  end

  defp parse_place(place) do
    case place["events"] do
      %{"data" => events} -> create_events_for_venue(place, events)
      nil -> []
    end
  end

  defp create_events_for_venue(place, events) do
    Enum.map(events, &create_event(place, &1))
  end

  defp create_event(place, event_map) do
    description = event_map["name"]
    venue_name = place["name"]
    detailed_description = event_map["description"]
    venue_about = place["about"]
    event_id = event_map["id"]
    venue_id = place["id"]
    cover_pic = get_in(place, ["cover", "source"])
    creator_pic = get_in(place, ["picture", "data", "url"])
    create_time = (DateTime.utc_now() |> DateTime.to_unix()) * 1000
    position = Map.get(place, "location", %{})
    category = Map.get(event_map, "category")
    start_time = event_map["start_time"]
    end_time = event_map["end_time"]

    venue = %{
      id: venue_id,
      name: venue_name,
      description: venue_about
    }

    event_data = %EventData{
      id: event_id,
      category: category,
      description: description,
      start_time: start_time,
      end_time: end_time,
      detailed_description: detailed_description,
      create_time: create_time,
      creator_pic: creator_pic,
      event_pic: cover_pic,
      position: %{
        latitude: position["latitude"],
        longitude: position["longitude"],
        address: position["street"]
      },
      venue: venue
    }

    {event_data, venue}
  end
end
