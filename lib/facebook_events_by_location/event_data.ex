defmodule FacebookEventsByLocation.EventData do
  defstruct id: nil,
            category: nil,
            description: nil,
            start_time: nil,
            end_time: nil,
            time_from_now: nil,
            detailed_description: nil,
            create_time: nil,
            creator_pic: nil,
            event_pic: nil,
            position: %{},
            venue: nil
end
