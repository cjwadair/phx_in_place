# PhxInPlace

**Inline editing package for the Phoenix Framework based on the rails gem best_in_place.**

Based on the Rails gem [best_in_place](https://github.com/bernat/best_in_place), phx_in_place enables unobtrusive, inline editing via Phoenix channels. The package consists of a view helper, javascript event listeners and a server side channel helper method that when set up will automatically update your application database and views whenever a user changes a field value.

Basic Example:
```javascript
<%= phx_in_place @product, :category %>
//<input class="pip-input" hash="<<hashed value here>>" name="category" value="251.00" style="background: initial;">
```

Optional parameters provide support for styling and formatting:
```javascript
<%= phx_in_place @product, :name, class="input-lg", display_as: :number_to_currency, display_options: [precision: 2, unit: "$"], type: "textarea" %>
```

**For a full demo of PhxInPlace in action, [click here](https://phx-in-place-demo.herokuapp.com/)**


## Installation

Adding phx_in_place to an existing application with one or more channels already set up is easy and straight forward. If you are unsure how to set up a Phoenix Channel, please see the [Phoenix Channels guide](https://hexdocs.pm/phoenix/channels.html#content) for more information.

Include [phx_in_place](https://github.com/cjwadair/phx_in_place) as a dependency in the mix.exs file:

```elixir
def deps do
  [
    {:phx_in_place, "0.1.3"}
  ]
end
```

and run `mix deps.get` to install dependencies:

```
  mix deps.get
```

then add the following to your package.json file:

```
"dependencies": {
    ...
    "phx_in_place": "file:../deps/phx_in_place"
  },
```

and run `npm install` from the same directory that your package.json file is located in (normally the /assets folder):

```
npm install
```

### Server-side set up

`import PhxInPlace` into your appName_web.ex file to make it available in all of your templates:

```elixir
defmodule YourAppNameWeb do
  ...
  def view do
    quote do
      #other import, use and alias statements
      import PhxInPlace
    end
  end
  ...
end
```

and `use PhxInPlace.ChannelManager` in your channels:

```elixir
  # in my_channel.ex
  defmodule AppName.MyChannel do
    use Phoenix.Channel
    use PhxInPlace.ChannelManager
  end
```

then add the following to your config.exs file:

```elixir
  config :phx_in_place,
    repo: AppName.RepoName,
    endpoint: AppNameWeb.Endpoint
```

### Client-side set up

`import phx_in_place` into your app.js after your import for your socket.js file:

```javascript
  import "phoenix_html"
  import socket from './socket'
  import * as pip from "phx_in_place"
```

and add the phx_in_place event listeners to your pages:

```javascript
  channel.join()
    .receive("ok", message => {
      pip.addListeners(channel);
    })
    .receive("error", resp => {
      console.warn("Unable to join", resp)
    });
```

## Usage

### phx_in_place (phx_in_place struct(), :field, options)

View helper for generating input fields for inline editing:

```elixir
 <%= phx_in_place @product, :name %>
 #<input class="pip-input" hash="SFMyNTY.g3QAAAACZAAEZGF0YWwAAAABaAJkACpFbGl4aXIuU2l0ZWxpbmVQaG9lbml4LlN1cHBsaWVycy5CY2xpc3RpbmdiAAAHTmpkAAZzaWduZWRuBgAvG0InYwE.aJPlnBRX1nuKx8Bdyo8P_UTpRYIyO24aQaYknQJ2Q50" name="name" value="251.00" style="background: initial;">
```

Hash value contains the name of the struct and the id of the record in question. Values are signed using Phoenix.Token to prevent tampering but are not encrypted. See the [Phoenix.Token](https://hexdocs.pm/phoenix/Phoenix.Token.html#content) module for details.

**Params:**

 - **struct (required)**: The Ecto query struct containing the data to be displayed and managed
 - **field (required)** : The name of the field to be displayed passed as an atom

**Options**

- **type (string)**: The name of the input type you want to create. Default to type="input".
- **class (string)**: A string containing the names of any additional classes to be added to the element being created.
- **display_as (atom)**: The name of the formatting helper to apply to the output value passed as an atom. Supported options include **:number_to_currency, :number_to_percentage, and :number_to_delimited**. See the [Number]() Hex Package for more details.
- **display_options (list)**: option values for the display_as field. See the Number Hex package for more details. Basic defaults have been set in the phx_in_place config.exs file and can be overridden in your apps config.exs file if required.


### phx_in_place_if (phx_in_place_if condition, struct, field, OPTIONS)

Similar to the phx_in_place helper but with a condition as the first parameter.

```elixir
  <%= phx_in_place_if @user.type=='admin', @product, :supplier_id %>
```

if `@user.type=='admin'` is false, a non-editable `<span></span>` tag is generated. Otherwise, the output is the same as the phx_in_place method above. This is useful for enforcing authorization rules.

## Post Update Callbacks

The event handlers that phx_in_place adds to your code will handle database updates and change the value of the input field automatically. For additional post-update event handling, you can listen to the `pip:update:success` and `pip:update:error` events as follows:

```javascript
  document.addEventListener('pip:update:success', function (e) {
      //add your success event callbacks here
  }, false);

  document.addEventListener('pip:update:error', function (e) {
      //add your failure event callbacks here
  }, false);
```

These callbacks can be used to trigger additional client side javascript updates or channel events for server side processing.

## Examples

### Using the :display_as option

The display_as option works with the formatting options provided through the Numbers Hex package. `:number_to_currency`, `:number_to_percentage`, and `:number_to_delimited` are currently supported.

```
  <%= phx_in_place @product, :name, display_as: :number_to_currency %>
```

Application wide defaults for Number formatting can be set in your config.exs file. See [Number documentation](https://hexdocs.pm/number/Number.html) for details on configuration options.

To override the defaults on a case by case basis, display_options: can be set directly within the phx_in_place tag:  

```
  <%= phx_in_place @product, :name, display_as: :number_to_currency, display_options: [precision: 2, unit: "$"] %>
```

### Adding custom classes

Using the class option will add a list of additional class names to the input tags generated by phx_in_place. This is useful for adding custom styles to your input tags or for working with 3rd party libraries and frameworks such as Bootstrap:

```
  <%= phx_in_place @product, :name, class="btn btn-lg" %>
```

### Setting tag type

Currently, phx_in_place supports input and textarea as field type options with input being the default:

**input tag examples**

```
  <%= phx_in_place @product, :name, class="btn btn-lg" %>
  <%= phx_in_place @product, :name, class="btn btn-lg", type: "input" %>
```

**textarea tag example**

```
  <%= phx_in_place @product, :name, class="btn btn-lg", type: "textarea" %>
```
