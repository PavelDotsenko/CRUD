defmodule CRUD do
  @moduledoc """
  A module for easy access to the database.
  """

  @moduledoc since: "1.0.4"

  use Ecto.Schema

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import Ecto.Query, only: [from: 2, where: 2, where: 3, offset: 2]

      @cont Keyword.get(opts, :context)

      @doc """
      Returns the current Repo
      """
      def context(), do: @cont

      @doc """
      Adds a new entity to the database
      ## Takes in parameters:
        - `mod`:  Module
        - `opts`: Map or paramatras key: value separated by commas

      ## Returns:
        - `{:ok, struct}`
        - `{:error, error as a string or list of errors}`

      ## Examples:
        - `iex> MyApp.CRUD.add(MyApp.MyModule, %{key1: value1, key2: value2})`
          `{:ok, struct}`
        - `iex> MyApp.CRUD.add(MyApp.MyModule, key1: value1, key2: value)`

          `{:ok, struct}`
      """
      def add(mod, opts), do: @cont.insert(set_field(mod, opts)) |> response(mod)

      @doc """
      Retrieves structure from DB

      ## Takes in parameters:
        - Using `id` records from the database
          - `mod`:  Module
          - `id`: Structure identifier in the database
        - Search by a bunch of `keys: value` of a record in the database
          - `mod`:  Module
          - `opts`: Map or paramatras `keys: value` separated by commas

      ## Returns:
        - `{:ok, struct}`
        - `{:error, error as a string}`

      ## Examples:
        - `iex> MyApp.CRUD.add(MyApp.MyModule, 1)`

          `{:ok, struct}`
        - `iex> MyApp.CRUD.add(MyApp.MyModule, id: 1)`

          `{:ok, struct}`
        - `iex> MyApp.CRUD.add(MyApp.MyModule, %{id: 1})`

          `{:ok, struct}`
      """
      def get(mod, id) when is_integer(id) or is_binary(id) do
        @cont.get(mod, id) |> response(mod)
      end

      @doc """
      Retrieves structure from DB

      ## Takes in parameters:
        - Using `id` records from the database
          - `mod`:  Module
          - `id`: Structure identifier in the database
        - Search by a bunch of `keys: value` of a record in the database
          - `mod`:  Module
          - `opts`: Map or paramatras `keys: value` separated by commas

      ## Returns:
        - `{:ok, struct}`
        - `{:error, error as a string}`

      ## Examples:
        - `iex> MyApp.CRUD.add(MyApp.MyModule, 1)`

          `{:ok, struct}`
        - `iex> MyApp.CRUD.add(MyApp.MyModule, id: 1)`

          `{:ok, struct}`
        - `iex> MyApp.CRUD.add(MyApp.MyModule, %{id: 1})`

          `{:ok, struct}`
      """
      def get(mod, opts) when is_list(opts) or is_map(opts) do
        @cont.get_by(mod, opts_to_map(opts)) |> response(mod)
      end

      @doc """
      Returns a list of structures from the database corresponding to the given Module

      ## Takes in parameters:
        - `mod`: Module

      ## Returns:
        - `{:ok, list of structures}`
        - `{:ok, []}`

      ## Examples
        - `iex> MyApp.CRUD.get_all(MyApp.MyModule)`

        `{:ok, list of structures}`
      """
      def get_all(mod) do
        {:ok, @cont.all(from(item in mod, select: item, order_by: item.id))}
      end

      @doc """
      Returns a list of structures from the database corresponding to the given Module

      ## Takes in parameters:
        - `mod`:  Module
        - `opts`: Map or paramatras `keys: value` separated by commas

      ## Returns
        - `{:ok, list of structures}`
        - `{:ok, []}`

      ## Examples
        - `iex> MyApp.CRUD.add(MyApp.MyModule, id: 1)`

          `{:ok, list of structures}`
        - `iex> MyApp.CRUD.add(MyApp.MyModule, %{id: 1})`

          `{:ok, list of structures}`
      """
      def get_all(mod, opts) when is_list(opts) or is_map(opts) do
        {:ok, @cont.all(from(i in mod, select: i, order_by: i.id) |> filter(opts))}
      end

      @doc """
      Returns the specified number of items for the module

      ## Takes in parameters:
        - `mod`:   Module
        - `limit`: Number of items to display

      ## Returns
        - `{:ok, list of structures}`
        - `{:ok, []}`

      ## Examples
        - `iex> MyApp.CRUD.get_few(MyApp.MyModule, 200)`

          `{:ok, list of structures}`
      """
      def get_few(mod, limit) when is_integer(limit) do
        {:ok, @cont.all(from(i in mod, select: i, order_by: i.id, limit: ^limit))}
      end

      @doc """
      Returns the specified number of items for a module starting from a specific item

      ## Takes in parameters:
        - `mod`:   Module
        - `limit`: Number of items to display
        - `offset`: First element number

      ## Returns
        - `{:ok, list of structures}`
        - `{:ok, []}`

      ## Examples
        - `iex> MyApp.CRUD.get_few(MyApp.MyModule, 200, 50)`

          `{:ok, list of structures}`
      """
      def get_few(mod, limit, offset) when is_integer(limit) and is_integer(offset) do
        query = from(i in mod, select: i, order_by: i.id, limit: ^limit, offset: ^offset)
        {:ok, @cont.all(query)}
      end

      @doc """
      Returns the specified number of items for a module starting from a specific item

      ## Takes in parameters:
        - `mod`:   Module
        - `limit`: Number of items to display
        - `opts`: Map or paramatras `keys: value` separated by commas

      ## Returns
        - `{:ok, list of structures}`
        - `{:ok, []}`

      ## Examples
        - `iex> MyApp.CRUD.get_few(MyApp.MyModule, 200, key: value)`

          `{:ok, list of structures}`
        - `iex> MyApp.CRUD.get_few(MyApp.MyModule, 200, %{key: value})`

          `{:ok, list of structures}`
      """
      def get_few(mod, limit, opts) when is_list(opts) or is_map(opts) do
        query = from(i in mod, select: i, order_by: i.id, limit: ^limit)
        {:ok, @cont.all(query |> filter(opts))}
      end

      @doc """
      Returns the specified number of items for a module starting from a specific item

      ## Takes in parameters:
        - `mod`:   Module
        - `limit`: Number of items to display
        - `offset`: First element number
        - `opts`: Map or paramatras `keys: value` separated by commas

      ## Returns
        - `{:ok, list of structures}`
        - `{:ok, []}`

      ## Examples
        - `iex> MyApp.CRUD.get_few(MyApp.MyModule, 200, 50, key: value)`

          `{:ok, list of structures}`
        - `iex> MyApp.CRUD.get_few(MyApp.MyModule, 200, 50, %{key: value})`

          `{:ok, list of structures}`
      """
      def get_few(mod, limit, offset, opts) when is_list(opts) or is_map(opts) do
        query = from(i in mod, select: i, limit: ^limit)
        {:ok, @cont.all(query |> filter(opts) |> offset(^offset))}
      end

      @doc """
      Makes changes to the structure from the database

      ## Takes in parameters:
        - `item`: Structure for change
        - `opts`: Map or paramatras `keys: value` separated by commas

      ## Returns
        - `{:ok, list of structures}`
        - `{:ok, []}`

      ## Examples
        - `iex> MyApp.CRUD.update(item, key: value)`

          `{:ok, list of structures}`
        - `iex> MyApp.CRUD.update(item, %{key: value})`

          `{:ok, list of structures}`
      """
      def update(item, opts) when is_struct(item),
        do: item.__struct__.changeset(item, opts_to_map(opts)) |> @cont.update()

      @doc """
      Makes changes to the structure from the database

      ## Takes in parameters:
        - `mod`: Module
        - `id`: Structure identifier in the database
        - `opts`: Map or paramatras `keys: value` separated by commas

      ## Returns
        - `{:ok, structure}`
        - `{:ok, error as a string or list of errors}`

      ## Examples
        - `iex> MyApp.CRUD.update(MyApp.MyModule, 1, key: value)`

          `{:ok, structure}`
        - `iex> MyApp.CRUD.update(MyApp.MyModule, 1, %{key: value})`

          `{:ok, structure}`
      """
      def update(mod, id, opts) when is_integer(id) or is_binary(id),
        do: get(mod, id) |> update_response(opts)

      @doc """
      Makes changes to the structure from the database

      ## Takes in parameters:
        - `mod`: Module
        - `key`: Field from structure
        - `val`: Field value
        - `opts`: Map or paramatras `keys: value` separated by commas

      ## Returns
        - `{:ok, structure}`
        - `{:error, error as a string or list of errors}`

      ## Examples
        - `iex> MyApp.CRUD.update(MyApp.MyModule, key, 1, key: value)`

          `{:ok, structure}`
        - `iex> MyApp.CRUD.update(MyApp.MyModule, key, 1, %{key: value})`

          `{:ok, structure}`
      """
      def update(mod, key, val, opts), do: get(mod, [{key, val}]) |> update_response(opts)

      @doc """
      Removes the specified structure from the database

      ## Takes in parameters:
        - `item`: Structure

      ## Returns
        - `{:ok, structure}`
        - `{:error, error as a string or list of errors}`

      ## Examples
        - `iex> MyApp.CRUD.delete(structure)`

          `{:ok, structure}`
      """
      def delete(item) when is_struct(item) do
        try do
          @cont.delete(item)
        rescue
          _ -> {:error, module_title(item) <> " is not fount"}
        end
      end

      @doc """
      Removes the specified structure from the database

      ## Takes in parameters:
        - `mod`: Module
        - `id`: Structure identifier in the database

      ## Returns
        - `{:ok, structure}`
        - `{:error, error as a string or list of errors}`

      ## Examples
        - `iex> MyApp.CRUD.delete(MyApp.MyModule, 1)`

          `{:ok, structure}`
      """
      def delete(mod, id), do: get(mod, id) |> delete_response()

      @doc """
      Returns a list of structures in which the values of the specified fields partially or completely correspond to the entered text

      ## Takes in parameters:
        - `mod`: Module
        - `id`: Structure identifier in the database

      ## Returns
        - `{:ok, list of structures}`
        - `{:ok, []}`

      ## Examples
        - `iex> MyApp.CRUD.find(MyApp.MyModule, key: "sample")`

          `{:ok, list of structures}`
        - `iex> MyApp.CRUD.find(MyApp.MyModule, %{key: "sample"})`

          `{:ok, list of structures}`
      """
      def find(mod, opts),
        do: from(item in mod, select: item) |> find(opts_to_map(opts), Enum.count(opts), 0)

      @doc """
      Checks if the given structure exists in the database

      ## Takes in parameters:
        - Using `id` records from the database
          - `mod`:  Module
          - `id`: Structure identifier in the database
        - Search by a bunch of `keys: value` of a record in the database
          - `mod`:  Module
          - `opts`: Map or paramatras `keys: value` separated by commas

      ## Returns
        - true
        - false

      ## Examples
        - `iex> MyApp.CRUD.exist?(MyApp.MyModule, 1)`

          `true`
        - `iex> MyApp.CRUD.exist?(MyApp.MyModule, key: 1)`

          `{:ok, list of structures}`
        - `iex> MyApp.CRUD.exist?(MyApp.MyModule, %{key: 1})`

          `{:ok, list of structures}`
      """
      def exist?(mod, opts), do: @cont.exists?(mod, map_to_opts(opts))

      defp set_field(mod, opts), do: mod.changeset(mod.__struct__, opts_to_map(opts))

      defp map_to_opts(map) when is_map(opts), do: Map.to_list(map)
      defp map_to_opts(map) when is_list(opts), do: map

      defp opts_to_map(opts) when is_map(opts), do: opts

      defp opts_to_map(opts) when is_list(opts),
        do: Enum.reduce(opts, %{}, fn {key, value}, acc -> Map.put(acc, key, value) end)

      defp find(query, opts, count, acc) do
        {key, val} = Enum.at(opts, acc)
        result = query |> where([i], ilike(field(i, ^key), ^"%#{val}%"))

        if acc < count - 1,
          do: find(result, opts, count, acc + 1),
          else: {:ok, @cont.all(result)}
      end

      defp filter(query, opts), do: filter(query, opts, Enum.count(opts), 0)

      defp filter(query, opts, count, acc) do
        fields = Map.new([Enum.at(opts, acc)]) |> Map.to_list()
        result = query |> where(^fields)

        if acc < count - 1, do: filter(result, opts, count, acc + 1), else: result
      end

      defp module_title(mod) when is_struct(mod), do: module_title(mod.__struct__)
      defp module_title(mod), do: Module.split(mod) |> Enum.at(Enum.count(Module.split(mod)) - 1)

      defp error_handler(err) when is_struct(err),
        do: Enum.map(err.errors, fn {key, {msg, _}} -> error_str(key, msg) end)

      defp error_handler(err) when is_tuple(err),
        do: Enum.map([err], fn {_, message} -> message end)

      defp error_handler(error), do: error

      defp delete_response({:error, reason}), do: {:error, error_handler(reason)}
      defp delete_response({:ok, item}), do: delete(item)

      defp update_response({:error, reason}, _opts), do: {:error, error_handler(reason)}
      defp update_response({:ok, item}, opts), do: update(item, opts)

      defp response(nil, mod), do: {:error, module_title(mod) <> " not found"}
      defp response({:error, reason}, _module), do: {:error, error_handler(reason)}
      defp response({:ok, item}, _module), do: {:ok, item}
      defp response(item, _module), do: {:ok, item}

      defp error_str(key, msg), do: "#{Atom.to_string(key) |> String.capitalize()}: #{msg}"
    end
  end
end
