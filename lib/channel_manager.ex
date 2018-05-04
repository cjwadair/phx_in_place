defmodule PhxInPlace.ChannelManager do

  @moduledoc """
    Handles automatic updating of phx_in_place fields when called from a channel.
  """
  import Number.{Currency, Percentage, Delimit}

  # TODO: Confirm if these are needed or not...
  # @secret_key Application.get_env(:phx_in_place, :endpoint)
  # @tokenHandler Application.get_env(:phx_in_place, :tokenHandler)

  # user when testing for good/bad results...
  # @secret_key "ZQhf4bLlNwh7Hjs48UT+YXVkrjAeeiF3WMIEt8tEwfzelcsWvFqKhMNEbrYMYqHR"

  defmacro __using__(params) do
    quote do

      @repo unquote(params[:repo_name])
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
            IO.puts "verify and update returned: #{inspect result}"
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
    case verify_token(payload["hash"]) do
      {:ok, resp} ->

        attrs = cleanChangeValues(payload["changes"], payload["formatting"])

        IO.puts "ATTRS: #{inspect attrs}"

        case do_update(repo, resp, attrs) do
          {:ok, resp} ->
            {field, value} = attrs |> Enum.at(0)

            new_value =
            resp
            |> Map.get(field)
            |> format_value(payload["formatting"])

          {:error, msg} -> {:error, msg}
        end

      {:error, msg} ->
        IO.warn "PIP failed to decrypt token with message: #{msg}"
        {:error, msg}
    end
  end

  defp cleanChangeValues(attrs, format) when is_nil(format) do
    convert_keys_to_atoms(%{}, attrs) |> Enum.at(0)
  end

  # TODO: Add handlers for other types display_as options
  defp cleanChangeValues(attrs, format) do
    attrs = case format do
      "number_to_currency" -> strip_formatting(attrs)
      "number_to_percentage" -> strip_formatting(attrs)
      _ -> attrs
    end
    convert_keys_to_atoms(%{}, attrs) |> Enum.at(0)
  end

  # TODO: Improve regex to filter out all non-numeric values
  defp strip_formatting(attrs) do
    result = for {k,v} <- attrs do
      {k, String.replace(v, ~r/[$#W%\s]/, "")}
    end
  end

  # TODO: This is copied from phx_in_place - move to helper and share code?
  defp format_value(value, format) do

    #handles case where nil value passed through for options
    # options = if is_nil(options), do: [], else: options
    options = []

    case format do
      "number_to_currency" -> {:ok, number_to_currency(value, options)}
      # "number_to_percentage" -> {:ok, number_to_percentage(value, options)}
      # "number_to_delimited" -> {:ok, number_to_delimited(value, options)}
      _ -> {:ok, value}
    end
  end

  # checks that a valid signed token has been passed in with the update request.
  defp verify_token(token) do
    Application.get_env(:phx_in_place, :tokenHandler).verify(Application.get_env(:phx_in_place, :endpoint), "user salt", token, max_age: 886400)
  end

  # updates the repo defined in the pip config
  defp do_update(repo, resp, attrs) do
    {struct, id} = resp |> Enum.at(0)
    struct
      |> repo.get!(id)
      |> struct.changeset(attrs)
      |> repo.update()
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
