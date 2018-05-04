defmodule ChannelManagerTest do
  use ExUnit.Case
  doctest PhxInPlace

  validPayload = %{"changes" => %{"input_quote" => "331"}, "hash" => "SFMyNTY.g3QAAAACZAAEZGF0YWwAAAABaAJkACpFbGl4aXIuU2l0ZWxpbmVQaG9lbml4LlN1cHBsaWVycy5CY2xpc3RpbmdiAAAHTmpkAAZzaWduZWRuBgBzf_MHYwE.p1oW9puBlfUI97ggiQQXvpM4pim6Dcv6l4jwEiEDV4k", "record_type" => nil}

  @tokenHander Application.get_env(:phx_in_place, :tokenHandler)

  repo = Application.get_env(:phx_in_place, :repo)

  # test "returns an error if payload does not contain a hash key-value pair" do
  #   repo = Application.get_env(:phx_in_place, :repo)
  #   payload = %{"changes" => %{"input_quote" => "72.45"}, "record_type" => nil}
  #   result = PhxInPlace.ChannelManager.verify_and_update(repo, payload)
  #   assert {:error, _} = result
  # end
  #
  # test "returns correct error when an invalid token is provided in hash" do
  #   repo = Application.get_env(:phx_in_place, :repo)
  #   payload = %{"changes" => %{"input_quote" => "72.45"}, "record_type" => nil, "hash" => "fake_token"}
  #   result = PhxInPlace.ChannelManager.verify_and_update(repo, payload)
  #   assert {:error, _} = result
  # end
  #
  # test "returns OK tuple when valid token provided" do
  #   repo = Application.get_env(:phx_in_place, :repo)
  #   payload = %{"changes" => %{"input_quote" => "72.45"}, "record_type" => nil, "hash" => "valid_token"}
  #   result = PhxInPlace.ChannelManager.verify_and_update(repo, payload)
  #   assert {:ok, _} = #should ultimately return the update successful information
  # end

end
