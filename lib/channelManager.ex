defmodule PhxInPlace.ChannelManager do

  # use Phoenix.Channel
  # import Ecto.Changeset

  defmacro __using__(_) do
    quote do

      @doc """
      Joins the channel when called from client side JS file.
      """
      def join(name, payload, socket) do
        {:ok, "successfully joined", socket}
      end

      @doc """
      Handles the pip_update event when called from client side js
      and updates the database for the applicable record
      """
      def handle_in("pip_update", payload, socket) do
        struct = String.to_atom(payload["record_type"])
        IO.puts "PAYLOAD IS: #{payload}"
        #Assumes only 1 change per request - probably fine but should
        #consider if multiple changes might need to be accomodated...
        temp = %{}
            |> convert_keys_to_atoms(payload["changes"])
            |> Enum.at(0)

        @repo.get(struct, payload["id"])
          |> struct.changeset(temp)
          |> @repo.update!()

        # Do I need to use a case here to handle any error situations?
        {:reply, {:ok, %{}}, socket}
      end

      defp convert_keys_to_atoms(map, kvpairs) do
        for {k,v} <- kvpairs do
          case is_binary(k) do
            true -> Map.put(map, String.to_atom(k), v)
            false -> Map.put(map, k, v)
          end
        end
      end

    end
  end
end
