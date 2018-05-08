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

  test "returns formatted value when formatting is specified" do
    payload = %{"id" => @valid_id, "changes" => %{"input_quote" => "72.45"}, "hash" => @valid_hash, "record_type" => nil, "formatting" => "number_to_currency"}
    result = PhxInPlace.ChannelManager.verify_and_update(@repo, payload)
    expected = {:ok, "$ 72.45"}
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



  # DONT NEED? correct result is assumed if handle in ultimately returns correctly
  # test "returns OK tuple when valid token provided" do
  #   repo = Application.get_env(:phx_in_place, :repo)
  #   payload = %{"changes" => %{"input_quote" => "72.45"}, "record_type" => nil, "hash" => "valid_token"}
  #   result = PhxInPlace.ChannelManager.verify_and_update(repo, payload)
  #   assert {:ok, _} = #should ultimately return the update successful information
  # end

  # test "returns error if no attrs are provided in the payload" do
  #   assert {:error, _} = 2
  # end

  # test "processes correctly when value in payload is formatted" do
  #
  # end
  #
  # test "processes correctly when value in playload is not formatted" do
  #
  # end


end
