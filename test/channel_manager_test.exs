defmodule ChannelManagerTest do
  use ExUnit.Case
  doctest PhxInPlace

  @valid_hash Application.get_env(:phx_in_place, :valid_hash)
  @invalid_hash Application.get_env(:phx_in_place, :invalid_hash)
  @repo Application.get_env(:phx_in_place, :repo)
  @valid_id "37"
  @invalid_id "54"

  test "returns an error if payload does not contain a hash key-value pair" do
    payload = %{"changes" => %{"input_quote" => "72.45"}, "record_type" => nil}
    result = PhxInPlace.ChannelManager.verify_and_update(@repo, payload)
    assert {:error, :missing} = result
  end

  test "returns error when an invalid token is provided in hash" do
    payload = %{"changes" => %{"input_quote" => "72.45"}, "record_type" => nil, "hash" => @invalid_hash}
    result = PhxInPlace.ChannelManager.verify_and_update(@repo, payload)
    assert {:error, :invalid} = result
  end

  test "returns error if reformatting the payload changes returns an error" do
    payload = %{"changes" => ["input_quote","72.45"], "hash" => @valid_hash, "record_type" => nil, "formatting" => "number_to_currency"}
    result = PhxInPlace.ChannelManager.verify_and_update(@repo, payload)
    assert {:error, "invalid attrs tuple received in cleanChangeValues"} = result
  end

  test "returns correctly formatted value when formatting for number_to_currency is specified" do
    payload = %{"id" => @valid_id, "changes" => %{"input_quote" => "72.45"}, "hash" => @valid_hash, "record_type" => nil, "formatting" => "number_to_currency"}
    result = PhxInPlace.ChannelManager.verify_and_update(@repo, payload)
    expected = {:ok, "$ 72.45"}
    assert result == expected
  end

  test "returns correctly formatted value when formatting for number_to_percentage is specified" do
    payload = %{"id" => @valid_id, "changes" => %{"input_quote" => "72.45666"}, "hash" => @valid_hash, "record_type" => nil, "formatting" => "number_to_currency", "display_options" => [precision: 3, unit: "£"]}
    result = PhxInPlace.ChannelManager.verify_and_update(@repo, payload)
    expected = {:ok, "£ 72.457"}
    assert result == expected
  end

  test "applies formatting options correctly" do
    payload = %{"id" => @valid_id, "changes" => %{"input_quote" => "72.45"}, "hash" => @valid_hash, "record_type" => nil, "formatting" => "number_to_percentage", }
    result = PhxInPlace.ChannelManager.verify_and_update(@repo, payload)
    expected = {:ok, "72.45%"}
    assert result == expected
  end

  test "returns unformatted value when no formatting specified" do
    payload = %{"id" => @valid_id, "changes" => %{"input_quote" => "72.45"}, "hash" => @valid_hash, "record_type" => nil}
    result = PhxInPlace.ChannelManager.verify_and_update(@repo, payload)
    expected = {:ok, "72.45"}
    assert result == expected
  end

  test "returns error when invalid ID provided" do
    payload = %{"id" => @invalid_id, "changes" => %{"input_quote" => "72.45"}, "hash" => @valid_hash, "record_type" => nil}
    result = PhxInPlace.ChannelManager.verify_and_update(@repo, payload)
    expected = {:ok, "72.45"}
    assert result == expected
  end
end
