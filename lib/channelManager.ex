defmodule PhxInPlace.ChannelManager do
  use Phoenix.Channel
  require Logger
  alias SitelinePhoenix.Suppliers
  use SitelinePhoenix.Pip.ChannelManager

  def handle_in("row_update", payload, socket) do
    case Suppliers.get_product!(payload["product_id"]) do
        product ->
          partialName = payload["row_type"] <> "_partial.html"
          html = return_row_data({:ok, product}, partialName, socket_ref(socket))
          {:reply, {:ok, %{product_id: product.id, html: html}}, socket}
        nil ->
          Logger.warn "Error getting Product!!!!"
          {:reply, {:error, %{reason: "response was nil"}}, socket}
    end
  end

  defp return_row_data(response, partialName, socket) do
    case response do
    {:ok, product} ->
      html = Phoenix.View.render_to_string(SitelinePhoenixWeb.ProductView, partialName, product: product)

    {:error, reason} ->
      {:error, %{reason: "channel: No such product #{inspect reason}"}}
    end
  end

end
