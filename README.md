# FacebookEventsByLocation

Fetches Facebook events by location

Facebook has disabled some APIs. So this may not work for now.

## Usage
get_events_by_location takes locations as a list of 2-item tuples ({lat, lng}) and options as a keyword list. Options take distance as meters from location center and a 
limit of events. Distance defaults to 5000 meters and limit defaults to 100 events.

```elixir
# Fetch events around two points in Helsinki
locations = [{60.16354687, 24.93021011}, {60.19052408, 24.89931107}]
opts = [distance: 300, limit: 10]
FacebookEventsByLocation.get_events_by_location(locations, opts)
```