defmodule FacebookEventsByLocation.UrlHelperTest do
  use ExUnit.Case
  alias FacebookEventsByLocation.UrlHelper

  test "return valid place url with default options" do
    assert UrlHelper.create_place_url({60, 50}) ==
             "https://graph.facebook.com/v2.7/search?type=place&center=60,50&distance=5000&limit=100&fields=id&access_token=test"
  end

  test "return valid place url with given options" do
    options = [distance: 10, limit: 10]

    assert UrlHelper.create_place_url({60, 50}, options) ==
             "https://graph.facebook.com/v2.7/search?type=place&center=60,50&distance=10&limit=10&fields=id&access_token=test"
  end

  test "return valid fetch places url" do
    assert UrlHelper.create_fetch_places_url([1, 2, 3]) ==
             "https://graph.facebook.com/v2.7/?ids=1,2,3&access_token=test&fields=id,name,about,emails,cover.fields(id,source),picture.type(large),category,category_list.fields(name),location,events.fields(id,type,name,cover.fields(id,source),picture.type(large),description,start_time,end_time,category,attending_count,declined_count,maybe_count,noreply_count)"
  end
end
