defmodule PhxInPlace do
  @moduledoc """
    Module for creating inline editable fields that make use of Phoenix.Channels to
    automatically update to the database when values are changed.
  """

  @doc """
  Puts to console Hello plus the config value for :test_config

  ## Examples

      iex> PhxInPlace.hello("Chris")
      :ok


  """
  @greeting Application.get_env(:phx_in_place, :greeting)

  def hello(name) do
    IO.puts "Say #{@greeting}, #{name}"
  end
end
