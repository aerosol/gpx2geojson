defmodule GPX2GeoJSON do
  def convert!(gpx) do
    {:ok, gpx} = SAXMap.from_string(gpx, ignore_attribute: false)

    name = get_in(gpx, ["gpx", "content", "trk", "content", "name", "content"])
    type = get_in(gpx, ["gpx", "content", "trk", "content", "type", "content"])

    gpx
    |> get_in(["gpx", "content", "trk", "content", "trkseg", "content", "trkpt"])
    |> Enum.map(fn point ->
      %{
        ele: f(point["content"]["ele"]["content"]),
        lat: f(point["lat"]),
        lon: f(point["lon"]),
        time: point["content"]["time"]["content"]
      }
    end)
    |> Enum.with_index()
    |> Enum.reduce(init(name, type), fn {point, index}, geojson ->
      geojson
      |> maybe_update_time(index, point)
      |> update_in(
        ["properties", "coordTimes"],
        &[point.time | &1]
      )
      |> update_in(["geometry", "coordinates"], &[[point.lon, point.lat, point.ele] | &1])
    end)
    |> update_in(["properties", "coordTimes"], &Enum.reverse(&1))
    |> update_in(["geometry", "coordinates"], &Enum.reverse(&1))
    |> wrap_feature()
  end

  defp init(name, type) do
    %{
      "type" => "Feature",
      "properties" => %{
        "name" => name,
        "type" => type,
        "time" => nil,
        "coordTimes" => []
      },
      "geometry" => %{
        "type" => "LineString",
        "coordinates" => []
      }
    }
  end

  defp f(number) do
    {float, ""} = Float.parse(number)
    float
  end

  defp maybe_update_time(geojson, 0, point) do
    put_in(
      geojson,
      ["properties", "time"],
      point.time
    )
  end

  defp maybe_update_time(geojson, _, _) do
    geojson
  end

  defp wrap_feature(feature) do
    %{
      "type" => "FeatureCollection",
      "features" => [
        feature
      ]
    }
  end
end
