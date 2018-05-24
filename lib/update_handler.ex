defmodule UpdateHandler do

  @moduledoc false

  @repo Application.get_env(:phx_in_place, :repo)

  def update_repo(struct, id, attrs) do
    changeset =
      struct
      |> @repo.get!(id)
      |> struct.changeset(attrs)

    case changeset.valid? do
      true -> @repo.update(changeset)
      false ->

        {:error,
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
              Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
              end)
            end)
            # errors: changeset.errors
        }
        # {:error, "validation errors detected"}

    end
  end



end
