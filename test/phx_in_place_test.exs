defmodule PhxInPlaceTest do
  use ExUnit.Case
  doctest PhxInPlace

  defmodule SandboxProduct do
   defstruct id: 1855, name: "Test 1-54", input_quote: 223.45, markup: 13.43
  end

  test "input tag correctly generated when no options provided" do
    query_result = Phoenix.HTML.safe_to_string(PhxInPlace.phx_in_place(%SandboxProduct{}, :input_quote))
    expected_result = "<input class=\"pip-input\" hash=\"fAket0kn\" name=\"input_quote\" value=\"223.45\"></input>"

    assert query_result == expected_result
  end

  test "input tag generated when class option provided" do
    query_result = Phoenix.HTML.safe_to_string(PhxInPlace.phx_in_place(%SandboxProduct{}, :name, class: "customClass"))

    assert String.contains?(query_result, "class=\"pip-input customClass\"")
  end

  test "input tag generated when allowable tag type provided" do
    query_result = Phoenix.HTML.safe_to_string(PhxInPlace.phx_in_place(%SandboxProduct{}, :name, type: :textarea))

    expected_result = "<textarea class=\"pip-input\" hash=\"fAket0kn\" name=\"name\" value=\"Test 1-54\">Test 1-54</textarea>"

    assert query_result == expected_result
  end

  test "returns error when source data missing" do
    query_result = PhxInPlace.phx_in_place(nil, :name)
    assert {:error, "Invalid or Missing Data Source"} = query_result
  end

  test "returns error if source is not a map or a struct" do
    list = [a: "1", b: "2", __struct__: "3"]
    query_result = PhxInPlace.phx_in_place(list, :name)
    assert {:error, "Invalid or Missing Data Source"} = query_result
  end

  test "returns error if source is not a valid struct object" do
    map = %{id: "33", name: "TEST"}
    query_result = PhxInPlace.phx_in_place(map, :name)
    assert {:error, "Source is not a valid struct object"} = query_result
  end

  test "returns error when field name missing" do
    query_result = PhxInPlace.phx_in_place(%SandboxProduct{}, nil)
    assert {:error, "Missing Field Name"} = query_result
  end

  test "returns error when field not found in source" do
    query_result = PhxInPlace.phx_in_place(%SandboxProduct{}, :bad_field_name)
    assert {:error, ":bad_field_name not found in source data provided"} = query_result
  end

  test "returns error when field name is not an Atom or String" do
    query_result = PhxInPlace.phx_in_place(%SandboxProduct{}, 77)
    assert {:error, "Field Name must be an Atom or a String"} = query_result
  end

  test "returns error if tag type not in allowed values" do
    query_result = PhxInPlace.phx_in_place(%SandboxProduct{}, :name, type: :select)
    assert {:error, "Invalid Tag Type provided."} = query_result
  end

  test "formats data correctly when display_as set to number_to_currency" do
    query_result = Phoenix.HTML.safe_to_string(PhxInPlace.phx_in_place(%SandboxProduct{}, :input_quote, display_as: :number_to_currency))

    expected_result = "<input class=\"pip-input\" display-type=\"number_to_currency\" hash=\"fAket0kn\" name=\"input_quote\" value=\"$ 223.45\"></input>"

    assert query_result == expected_result
  end

  test "display_as formatted correctly when helper options provided" do
    query_result = Phoenix.HTML.safe_to_string(PhxInPlace.phx_in_place(%SandboxProduct{}, :input_quote, display_as: :number_to_currency, display_options: [precision: 5, unit: "£"]))

    expected_result = "<input class=\"pip-input\" display-type=\"number_to_currency\" hash=\"fAket0kn\" name=\"input_quote\" value=\"£ 223.45000\"></input>"

    assert query_result == expected_result
  end

  test "formats data correctly when display_as set to number_to_percentage" do
    query_result = Phoenix.HTML.safe_to_string(PhxInPlace.phx_in_place(%SandboxProduct{}, :markup, display_as: :number_to_percentage))

    expected_result = "<input class=\"pip-input\" display-type=\"number_to_percentage\" hash=\"fAket0kn\" name=\"markup\" value=\"13.43%\"></input>"

    assert query_result == expected_result
  end

  test "formats data correctly when display_as set to number_to_delimited" do
    query_result = Phoenix.HTML.safe_to_string(PhxInPlace.phx_in_place(%SandboxProduct{}, :input_quote, display_as: :number_to_delimited))

    expected_result = "<input class=\"pip-input\" display-type=\"number_to_delimited\" hash=\"fAket0kn\" name=\"input_quote\" value=\"223.45\"></input>"

    assert query_result == expected_result
  end

  test "generates a size attribute on tag when a size option is provided" do
    query_result = Phoenix.HTML.safe_to_string(PhxInPlace.phx_in_place(%SandboxProduct{}, :input_quote, size: "10"))
    expected_result = "<input class=\"pip-input\" hash=\"fAket0kn\" name=\"input_quote\" size=\"10\" value=\"223.45\"></input>"

    assert query_result == expected_result
  end

end
