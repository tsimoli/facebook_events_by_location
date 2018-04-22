defmodule FacebookEventsByLocation.ResponseHelper do
  require Logger
  alias Poison.Parser

  def parse_response(%HTTPoison.Response{body: body, status_code: status_code})
      when status_code != 200 do
    Logger.error("Failed on request. Response was " <> body)
    {:error, status_code}
  end

  def parse_response(%HTTPoison.Response{body: body}) do
    Parser.parse!(body)
  end
end
