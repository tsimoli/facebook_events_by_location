defmodule FacebookEventsByLocation.UrlHelper do
  @events_base_url "https://graph.facebook.com/v2.7/?ids="
  @place_base_url "https://graph.facebook.com/v2.7/search?type=place"
  @access_token Application.get_env(:facebook_events_by_location, :access_token, "")
  @default_distance 5000
  @default_limit 100
  @event_fields [
    "id",
    "type",
    "name",
    "cover.fields(id,source)",
    "picture.type(large)",
    "description",
    "start_time",
    "end_time",
    "category",
    "attending_count",
    "declined_count",
    "maybe_count",
    "noreply_count"
  ]
  @fields [
    "id",
    "name",
    "about",
    "emails",
    "cover.fields(id,source)",
    "picture.type(large)",
    "category",
    "category_list.fields(name)",
    "location",
    "events.fields(#{Enum.join(@event_fields, ",")})"
  ]

  def create_place_url({lat, lng}, opts \\ []) do
    distance = Keyword.get(opts, :distance, @default_distance)
    limit = Keyword.get(opts, :limit, @default_limit)

    @place_base_url <>
      "&center=#{lat},#{lng}" <>
      "&distance=#{distance}" <>
      "&limit=#{limit}" <> "&fields=id" <> "&access_token=#{@access_token}"
  end

  def create_fetch_places_url(event_ids_group) do
    @events_base_url <>
      Enum.join(event_ids_group, ",") <>
      "&access_token=#{@access_token}" <> "&fields=#{Enum.join(@fields, ",")}"
  end
end
