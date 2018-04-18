# PhxInPlace

**Inline Editing package for Elixir and the Phoenix Framework based on the rails gem best_in_place.**

##Description

Based on the idea behind the rails gem best_in_place, phx_in_place enables unobtrusive, inline editing using Phoenix channels for updates instead of ajax calls.

The package consists of three parts:

1. A view helper that creates an html text_input field with the attributes necessary to support automatic updating of the data base.

2. Channel helpers  that simplify the set up a channel to work work with the view helpers and process updates to the database when the user updates a phx_in_place field on the client side.

3. Client side javascript to enable communication with the channel on the server side

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `phx_in_place` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:phx_in_place, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/phx_in_place](https://hexdocs.pm/phx_in_place).

###View Helper Set Up

Add the following to your appName_web.ex file to enable use of enable use of the phx_in_place view helper in all views and templates:

```elixir
  def view do
    #other import, use and alias statements go here
    import PhxInPlace
  end
```

Alternatively, you can add the import statement directly in the view you want to use it if you don't want to make it available across all views

##Channel Set Up

1. Add the following to the user_socket.ex file in the channels folder in your appName_web folder of your app:

```elixir
  channel "pip:*", SitelinePhoenix.PipChannel
```
**NOTE:** you can name your channel whatever you want.

2. Create a pip_channel.ex file in channels folder with the following content:

```elixir
  defmodule SitelinePhoenix.PipChannel do
    use Phoenix.Channel
    use PhxInPlace.ChannelManager
  end
```

3. Set confiugration variables in config.exs

```elixir
  config :phx_in_place,
  repo: YourAppName.RepoName
```

4. Add to app.js or appropriate file in your assets/js folder

```javascript
  import * as pip from "phx_in_place"

    (function(){

    //join the pip channel
    pip.join_channel();

    // Listen for updates on the pip channel.
    document.addEventListener('pip:update', function (e) {
        // push_row_update(e.target, 'pricing_row');
    }, false);

  })();
```

##Examples

**Creating a View Helper**

```elixir
alias PhxInPlace.phx_in_place

<%= phx_in_place @product, :price %>
<%= phx_in_place @product, :price, classes: "custom-input lg-input" %>
```

##Params:

- **Struct**(mandatory): The Ecto query struct containing the data to be displayed and managed
- **field**(mandatory): The name of the field to be displayed and managed

##Options:

- **:classes** - A string containing a list of any classes to be applied to the input field
- **:field_type** - The type of input field to be created. Default is text_input. Currently there are no other options available but select and other input fields will be added in future updates
- **:display_as** - Name of the formatting method to be applied to returned data (ie - :number_to_currency). Not implemented.
