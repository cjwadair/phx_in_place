defmodule FakeUpdateHandler do

  @moduledoc false

  def update_repo(_struct, id, attrs) do

    if id == "37" do
      {key, value} = Enum.at(attrs,0)

      payload = %{cspc: "2603873", id: 1855, input_quote: 384.19,
      inserted_at: ~N[2018-02-28 18:01:40.631012],
      product_id: 1862, retail_price: 12.71,
      updated_at: ~N[2018-02-28 18:01:40.631016], vintage: "2006"}

      {:ok, Map.put(payload, key, value) }
    else
      {:error, "invalid ID provided"}
    end
  end

end
