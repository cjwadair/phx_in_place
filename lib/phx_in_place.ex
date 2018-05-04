defmodule PhxInPlace do

  @moduledoc """
    Module for creating inline editable fields that make use of Phoenix.Channels to
    automatically update to the database when values are changed.
  """

  # Number provides convenience methods for formatting number values
  import Number.{Currency, Percentage, Delimit}

  @doc """
    Helper method to generate a custom input tag using the phx_in_place helper method.

    The resulting html is configured with the attributes phx_in_place needs to handle the updates automatically.

    example:
      <%= PhxInPlace.phx_in_place @product, :name, class: "test-class" %>
      <input class="pip-input test-class" data-struct="Elixir.SitelinePhoenix.Suppliers.Product" id="1855" name="name" value="Test 1-53" style="background: initial;">

    options:
      classes: [] - takes a list of custom classes to add to the element
      type: :type - to come. support for form types other than text_input
      display_as: :atom - to come - will support custom formatting of the input field value (eg - number_to_currency, etc)
  """
  def phx_in_place(source, field, opts \\ [])
  def phx_in_place(source, _field, _opts) when is_nil(source) or not is_map(source), do: {:error, "Invalid or Missing Data Source"}
  def phx_in_place(_source, field, _opts) when is_nil(field), do: {:error, "Missing Field Name"}

  # REVIEW: Should there be two versions of the tag generator? - one using hashed values and one using plain text?
  def phx_in_place(source, field, opts) do

    unless Map.has_key?(source, :__struct__) do
      {:error, "Source is not a valid struct object"}
    else

      #sets name to either {:ok, field} or {:error, reason}
      field_name = set_field_name(field)

      with {:ok, field_name} <- field_name,
        {:ok, type} <- set_tag_type(opts[:type]),
        {:ok, value} <- set_value(source, field, opts[:display_as], opts[:display_options]),
        {:ok, hash} <- hash_value(source.__struct__, source.id),
        {:ok, class} <- set_classes(opts[:class]),
        {:ok, display_type} <- set_display_type(opts[:display_as])
      do
        map = if is_nil(display_type) do
          %{type: type, value: value, class: class, name: field_name, hash: hash}
        else
          %{type: type, value: value, class: class, name: field_name, hash: hash, display_type: display_type}
        end
        Phoenix.HTML.Tag.content_tag(map[:type], "", set_attrs(map))
      else
        {:error, error} -> {:error, error}
      end
    end
  end

  @doc """
    Similar to phx_in_place/3 method but adds an if condition as the first parameters.
    Generates a phx_in_place content tag if condition is true or a non-editable span tag if false. Useful for handling authorization and user permissions.

    Example
    <%= PhxInPlace.phx_in_place_if condition, @product, :name, class: "test-class" %>

    if condition is true, returns:
    <input class="pip-input test-class" data-struct="Elixir.SitelinePhoenix.Suppliers.Product" id="1855" name="name" value="Test 1-53" style="background: initial;">

    if condition is false, returns:
    <span class="pip-input test-class" value="value">value</span
  """
  def phx_in_place_if(condition, source, field, opts \\ []) do
    case condition do
      true -> phx_in_place(source, field, opts)
      false -> generate_regular_tag(source, field, opts)
    end
  end

  # TODO: Need to fix this method to properly evaluate any conditions provided...
  # defp test_condition(condition) do
  #   case condition do
  #     true -> true
  #     false -> false
  #   end
  #   # some code here to test the condition that was provided....
  # end

  defp generate_regular_tag(source, field, opts) do
    with {:ok, value} <- set_value(source, field, nil, nil),
      {:ok, class} <- set_classes(opts[:class])
    do
      Phoenix.HTML.Tag.content_tag(:span, value, [class: class])
    else
      {:error, error} -> {:error, error}
    end
  end

  defp set_field_name(field) when is_binary(field), do: {:ok, field}
  defp set_field_name(field) when is_atom(field), do: {:ok, Atom.to_string(field)}
  defp set_field_name(_field), do: {:error, "Field Name must be an Atom or a String"}

  defp set_tag_type(type) when type in [:textarea, :input], do: {:ok, type}
  defp set_tag_type(type) when is_nil(type), do: {:ok, :input}
  defp set_tag_type(_type), do: {:error, "Invalid Tag Type provided."}

  defp set_value(source, field, format, helpers) do
    case Map.has_key?(source, field) do
      false -> {:error, "#{inspect field} not found in source data provided"}
      true ->
        source
        |> Map.get(field)
        |> format_value(format, helpers)
    end
  end

  defp format_value(value, format, _options) when is_nil(format), do: {:ok, value}
  defp format_value(value, format, options) do

    #handles case where nil value passed through for options
    options = if is_nil(options), do: [], else: options

    case format do
      :number_to_currency -> {:ok, number_to_currency(value, options)}
      :number_to_percentage -> {:ok, number_to_percentage(value, options)}
      :number_to_delimited -> {:ok, number_to_delimited(value, options)}
      _ -> {:ok, value}
    end
  end

  # TODO: Handle case where submitted display type is not an atom?
  defp set_display_type(format) do
    {:ok, Atom.to_string(format)}
  end
  defp set_display_type(_format), do: {:ok, nil}
  defp get_from_source(source, field) do
    case Map.fetch(source, field) do
      {:ok, result} -> {:ok, result}
      _ -> {:error, "#{inspect field} not found in the source data provided"}
    end
  end

  defp hash_value(hash, _) when hash == nil, do: {:ok, "not found"}
  defp hash_value(struct, id) do
    hash =
      Application.get_env(:phx_in_place, :tokenHandler).sign(Application.get_env(:phx_in_place, :endpoint), "user salt", "#{struct}": id)
    {:ok, hash}
  end

  defp set_classes(classes) when classes == nil, do: {:ok, "pip-input"}
  defp set_classes(classes), do: {:ok, "pip-input " <> classes}
  defp set_classes(classes),  do: {:ok, "pip-input " <> classes}
  defp set_attrs(map) do
    map
    |> Map.take([:class, :name, :value, :hash, :display_type])
    |> Map.to_list()
  end

end
