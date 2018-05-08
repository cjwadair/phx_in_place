defmodule FakeRepoService do
  @moduledoc false
  defmodule SandboxProduct do
    @moduledoc false
    defstruct id: 37, name: "Test 1-54", input_quote: 223.45, markup: 13.43
  end

  def get!(repo, id) do
    case id == "37" do
      true -> %SandboxProduct{}
      false -> {:error, "invalid ID"}
    end
  end

  def update(struct) do

  end

end
