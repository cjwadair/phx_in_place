defmodule PhxInPlace.ChannelManager do
  @moduledoc false
  
  import Number.{Currency, Percentage, Delimit}

  defmacro __using__(params) do
    quote do

      @repo Application.get_env(:phx_in_place, :repo)

      import PhxInPlace.ChannelManager

      @doc """
      Handles the pip_update event when called from client side JS
      and updates the database for the applicable record. See the Phoenix Channels documents for details.

      Called from client-side JS via channel.push:
      channel.push('pip_update', update_values)

      ## Example
      def handle_in("pip_update", %{hash: "HashKeyHere", changes: {name: "New Name"}}, socket)

      replies with {:ok, %{msg, value}} when successful or {:error, msg} when the update errors out so that any additional client side callbacks can be processed.
      """
      def handle_in("pip_update", payload, socket) do
        case verify_and_update(@repo, payload) do
          {:ok, result} ->
            {:reply, {:ok, %{msg: "update successful", value: result}}, socket}
          {:error, msg} ->
            {:reply, {:error, %{msg: msg}}, socket}
        end
      end
    end
  end

  @doc """
  Called from handle_in('pip_update', payload, socket). Verifies the hashed values in the phx_in_place field element and processes the
  database update if successful.
  """
  def verify_and_update(repo, payload) do
    with\
      {:ok, token_values} <- verify_token(payload["hash"]),
      {:ok, changes} <- cleanChangeValues(payload["changes"], payload["formatting"]),
      {:ok, resp} <- do_update(repo, token_values, changes)
    do
      process_result(resp, changes, payload["formatting"])
    else
      {:error, msg} -> {:error, msg}
    end
  end

  # checks that a valid signed token has been passed in with the update request.
  defp verify_token(token) do
    decoded_token = Application.get_env(:phx_in_place, :tokenHandler).verify(Application.get_env(:phx_in_place, :endpoint), "user salt", token, max_age: 886400)

    case decoded_token do
      {:error, msg} -> {:error, msg}
      _ -> {:ok, Tuple.to_list(decoded_token) |> Enum.at(1) |> Enum.at(0)}
    end
  end

  defp cleanChangeValues(attrs, format) when is_map(attrs) == false, do: {:error, "invalid attrs tuple received in cleanChangeValues"}

  defp cleanChangeValues(attrs, format) when is_nil(format) do
    attrs = convert_keys_to_atoms(%{}, attrs) |> Enum.at(0)
    {:ok,  attrs}
  end

  # TODO: Add handlers for other types display_as options
  defp cleanChangeValues(attrs, format) do
    attrs = case format do
      "number_to_currency" -> strip_formatting(attrs)
      "number_to_percentage" -> strip_formatting(attrs)
      _ -> {:ok, convert_keys_to_atoms(%{}, attrs) |> Enum.at(0)}
    end
    #attrs are returned as list containing a key value pair ie - [{"input_quote", "72.34"}]
    attrs = convert_keys_to_atoms(%{}, attrs) |> Enum.at(0)
    {:ok, attrs}
  end

  # TODO: Improve regex to filter out all non-numeric values
  defp strip_formatting(attrs) do
    result = for {k,v} <- attrs do
      {k, String.replace(v, ~r/[$#W%\s]/, "")}
    end
  end

  # updates the repo defined in the pip config
  defp do_update(repo, hash_values, attrs) do
    {struct, id} = hash_values
    response = Application.get_env(:phx_in_place, :updateHandler).update_repo(struct, id, attrs)
  end

  # inserts the updated value into the changes pair so that it can be passed back to the client for updating
  defp process_result(resp, attrs, format) do
    {field, value} = attrs |> Enum.at(0)
    resp
    |> Map.get(field)
    |> format_value(format) #get back {:ok, foramtted_value} pair
  end

  # TODO: This is copied from phx_in_place - move to helper and share code?
  defp format_value(value, format) do

    #handles case where nil value passed through for options
    # options = if is_nil(options), do: [], else: options
    options = []

    case format do
      "number_to_currency" -> {:ok, number_to_currency(value, options)}
      "number_to_percentage" -> {:ok, number_to_percentage(value, options)}
      "number_to_delimited" -> {:ok, number_to_delimited(value, options)}
      _ -> {:ok, value}
    end
  end

  #converts keys passed in from Javascript from strings to atoms if keys are strings
  # assumes only one pair is provided....
  defp convert_keys_to_atoms(map, kvpairs) do
    for {k,v} <- kvpairs do
      case is_binary(k) do
        true -> Map.put(map, String.to_atom(k), v)
        false -> Map.put(map, k, v)
      end
    end
  end

end
