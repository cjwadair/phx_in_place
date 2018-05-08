defmodule UpdateHandler do

  @moduledoc false

  @repo Application.get_env(:phx_in_place, :repo)

  def update_repo(struct, id, attrs) do
    struct
      |> @repo.get!(id)
      |> struct.changeset(attrs)
      |> @repo.update()
  end

end
