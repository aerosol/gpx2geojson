defmodule Gpx2geojsonTest do
  use ExUnit.Case

  test "works like https://mapbox.github.io/togeojson/ (II)" do
    fixture = File.read!("test/fixture.gpx")
    expected = File.read!("test/expected.json") |> Jason.decode!()
    converted = GPX2GeoJSON.convert!(fixture)

    assert converted["type"] == expected["type"]
    converted_feature = hd(converted["features"])
    expected_feature = hd(expected["features"])

    assert converted_feature["type"] == expected_feature["type"]
    assert converted_feature["properties"] == expected_feature["properties"]
    assert converted_feature["geometry"] == expected_feature["geometry"]

    refute Enum.empty?(converted_feature["geometry"])
    refute Enum.empty?(converted_feature["geometry"])

    assert expected == converted
  end
end
