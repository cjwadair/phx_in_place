defmodule PhxInPlaceIfTest do
  use ExUnit.Case
  doctest PhxInPlace

  defmodule SandboxProduct do
   defstruct id: 1855, name: "Test 1-54", input_quote: 223.45, markup: 13.43
  end

  test "phoenix_in_place_if generates a valid phx_in_place tag when condition is true" do
    query_result = Phoenix.HTML.safe_to_string(PhxInPlace.phx_in_place_if(true, %SandboxProduct{}, :input_quote))
    expected_result = "<input class=\"pip-input\" hash=\"fAket0kn\" name=\"input_quote\" value=\"223.45\"></input>"

    assert query_result == expected_result
  end

  test "phoenix_in_place_if generates an error when condition is false" do
    query_result = Phoenix.HTML.safe_to_string(PhxInPlace.phx_in_place_if(false, %SandboxProduct{}, :input_quote))
    expected_result = "<span class=\"pip-input\">223.45</span>"

    assert query_result == expected_result
  end

end
