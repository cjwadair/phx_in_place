defmodule FakeTokenService do

  @moduledoc false

  def sign( _, _, _) do
    "fAket0kn"
  end

  def verify(token) when is_nil(token), do: {:error, "token_missing"}

  def verify(_, _,token, _) do
    cond do
      token == nil -> {:error, :missing}
      token == Application.get_env(:phx_in_place, :valid_hash) -> {:ok, [{Application.get_env(:phx_in_place, :repo), "37"}]}
      token == Application.get_env(:phx_in_place, :invalid_hash) -> {:error, :invalid}
      true -> {:ok, [Application.get_env(:phx_in_place, :repo), "37"]}
    end

  end
end
