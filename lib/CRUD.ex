defmodule CRUD do
  @moduledoc """
  A module for easy access to the database.
  """

  @moduledoc since: "1.0.0"

  use Ecto.Schema

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import Ecto.Query, only: [from: 2, where: 2, where: 3, offset: 2]

      @cont Keyword.get(unquote(opts), :context)

      @behaviour unquote(__MODULE__)

      def context(), do: @cont

      def add(mod, opts), do: @cont.insert(set_field(mod, opts)) |> response(mod)

      def get(mod, id) when is_integer(id) or is_binary(id),
        do: @cont.get(mod, id) |> response(mod)

      def get(mod, opts) when is_list(opts) or is_map(opts),
        do: @cont.get_by(mod, opts_to_map(opts)) |> response(mod)

      def get_all(mod),
        do: {:ok, @cont.all(from(item in mod, select: item, order_by: item.id))}

      def get_all(mod, opts) when is_list(opts) or is_map(opts),
        do: {:ok, @cont.all(from(i in mod, select: i, order_by: i.id) |> filter(opts))}

      def get_all(mod, limit) when is_integer(limit),
        do: {:ok, @cont.all(from(i in mod, select: i, order_by: i.id, limit: ^limit))}

      def get_all(mod, limit, offset) when is_integer(limit) and is_integer(offset) do
        query = from(i in mod, select: i, order_by: i.id, limit: ^limit, offset: ^offset)
        {:ok, @cont.all(query)}
      end

      def get_all(mod, limit, opts) when is_list(opts) or is_map(opts) do
        query = from(i in mod, select: i, order_by: i.id, limit: ^limit)
        {:ok, @cont.all(query |> filter(opts))}
      end

      def get_all(mod, limit, offset, opts) when is_list(opts) or is_map(opts) do
        query = from(i in mod, select: i, limit: ^limit)
        {:ok, @cont.all(query |> filter(opts) |> offset(^offset))}
      end

      def update(item, opts) when is_struct(item),
        do: item.__struct__.changeset(item, opts_to_map(opts)) |> @cont.update()

      def update(mod, id, opts) when is_integer(id) or is_binary(id),
        do: get(mod, id) |> update_response(opts)

      def update(mod, key, val, opts), do: get(mod, [{key, val}]) |> update_response(opts)

      def delete(item) when is_struct(item) do
        try do
          @cont.delete(item)
        rescue
          _ -> {:error, module_title(item) <> " is not fount"}
        end
      end

      def delete(mod, id), do: get(mod, id) |> delete_response()

      def find(mod, opts),
        do: from(item in mod, select: item) |> find(opts_to_map(opts), Enum.count(opts), 0)

      defp set_field(mod, opts), do: mod.changeset(mod.__struct__, opts_to_map(opts))

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

  @doc """
  Returns the current Repo
  """
  @callback context() :: Module.t()

  @doc """
  ##### Adds a new entity to the database #####
  Takes in parameters:
    - CRUD.add/2:
      - `mod`:  Module
      - `opts`: Map or paramatras key: value separated by commas

  Returns `{:ok, struct}` or `{:error, error as a string or list of errors}`

  ## Examples
      iex> MyApp.CRUD.add(MyApp.MyModule, %{key1: value1, key2: value2})
      or
      iex> MyApp.CRUD.add(MyApp.MyModule, key1: value1, key2: value)
  """
  @callback add(mod :: Module.t(), opts :: List.t() | Map.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, List.t()} | {:error, String.t()}

  @doc """
  ##### Retrieves structure from DB #####
  Takes in parameters:
    - CRUD.get/2:
      - `mod`:  Module
      - `id`:   Structure identifier in the database
    - CRUD.get/2:
      - `mod`:  Module
      - `opts`: Map or paramatras key: value separated by commas

  Returns `{:ok, struct}` or `{:error, error as a string}`

  ## Examples
      iex> MyApp.CRUD.get(MyApp.MyModule, 1)
      or
      iex> MyApp.CRUD.add(MyApp.MyModule, "8892da9e-9cb5-49dd-922c-7371083cdd85")
      or
      iex> MyApp.CRUD.add(MyApp.MyModule, id: 1)
      or
      iex> MyApp.CRUD.add(MyApp.MyModule, %{id: 1})
  """
  @callback get(mod :: Module.t(), id :: String.t() | Integer.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, List.t()} | {:error, String.t()}

  @callback get(mod :: Module.t(), opts :: List.t() | Map.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, List.t()} | {:error, String.t()}

  @doc """
  ##### Gets a list of structures from the database #####
  Takes in parameters:
    - CRUD.get_all/1:
      - `mod`:    Module
    - CRUD.get_all/2:
      - `mod`:    Module
      - `limit`:  Number of items to display
    - CRUD.get_all/2:
      - `mod`:    Module
      - `opts`:   Map or paramatras key: value separated by commas
    - CRUD.get_all/3:
      - `mod`:    Module
      - `limit`:  Number of items to display
      - `offset`: Number of elements at the beginning of the list to skip
    - CRUD.get_all/3:
      - `mod`:    Module
      - `limit`:  Number of items to display
      - `opts`:   Map or paramatras key: value separated by commas
    - CRUD.get_all/4:
      - `mod`:    Module
      - `limit`:  Number of items to display
      - `offset`: Number of elements at the beginning of the list to skip
      - `opts`:   Map or paramatras key: value separated by commas

  Returns `{:ok, list}`

  ## Examples
      iex> MyApp.CRUD.get_all(MyApp.MyModule)
      or
      iex> MyApp.CRUD.get_all(MyApp.MyModule, 200)
      or
      iex> MyApp.CRUD.get_all(MyApp.MyModule, status: 1)
      or
      iex> MyApp.CRUD.get_all(MyApp.MyModule, %{status: 1})
      or
      iex> MyApp.CRUD.get_all(MyApp.MyModule, 200, 50)
      or
      iex> MyApp.CRUD.get_all(MyApp.MyModule, 200, status: 1)
      or
      iex> MyApp.CRUD.get_all(MyApp.MyModule, 200, %{status: 1})
      or
      iex> MyApp.CRUD.get_all(MyApp.MyModule, 200, 50, status: 1)
      or
      iex> MyApp.CRUD.get_all(MyApp.MyModule, 200, 50, %{status: 1})
  """
  @callback get_all(mod :: Module.t()) :: {:ok, List.t()}
  @callback get_all(mod :: Module.t(), opts :: List.t() | Map.t()) :: {:ok, List.t()}
  @callback get_all(mod :: Module.t(), limit :: Integer.t()) :: {:ok, List.t()}
  @callback get_all(mod :: Module.t(), limit :: Integer.t(), offset :: Integer.t()) ::
              {:ok, List.t()}
  @callback get_all(mod :: Module.t(), limit :: Integer.t(), opts :: List.t() | Map.t()) ::
              {:ok, List.t()}
  @callback get_all(
              mod :: Module.t(),
              limit :: Integer.t(),
              offset :: Integer.t(),
              opts :: List.t() | Map.t()
            ) ::
              {:ok, List.t()}

  @doc """
  ##### Changes the structure in the database #####
  Takes in parameters:
    - CRUD.update/2:
      - `item`: struct
      - `opts`: Map or paramatras key: value separated by commas
    - CRUD.update/3:
      - `mod`:  Module
      - `id`:   Structure identifier in the database
      - `opts`: Map or paramatras key: value separated by commas
    - CRUD.update/4:
      - `mod`:  Module
      - `key`:  Name of one of the fields in the structure
      - `val`:  Field value
      - `opts`: Map or paramatras key: value separated by commas

  Returns `{:ok, struct}` or `{:error, error as a string or list of errors}`

  ## Examples
      iex> MyApp.CRUD.update(struct, %{key1: value1, key2: value2})
      or
      iex> MyApp.CRUD.update(struct, key1: value1, key2: value)
      or
      iex> MyApp.CRUD.update(MyApp.MyModule, 5, %{key1: value1, key2: value})
      or
      iex> MyApp.CRUD.update(MyApp.MyModule, 5, key1: value1, key2: value)
      or
      iex> MyApp.CRUD.update(MyApp.MyModule, :id, 5, %{key1: value1, key2: value})
      or
      iex> MyApp.CRUD.update(MyApp.MyModule, :id, 5, key1: value1, key2: value)
  """
  @callback update(item :: Ecto.Schema.t(), opts :: List.t() | Map.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, List.t()} | {:error, String.t()}

  @callback update(mod :: Module.t(), id :: Integer.t() | String.t(), opts :: List.t() | Map.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, List.t()} | {:error, String.t()}

  @callback update(
              mod :: Module.t(),
              key :: Atom.t(),
              val :: Integer.t() | String.t(),
              opts :: List.t() | Map.t()
            ) ::
              {:ok, Ecto.Schema.t()} | {:error, List.t()} | {:error, String.t()}

  @doc """
  ##### Removes a structure from the database #####
  Takes in parameters:
    - CRUD.delete/1:
      - `item`: struct
    - CRUD.delete/2:
      - `mod`:  Module
      - `id`:   Structure identifier in the database

  Returns `{:ok, struct}` or `{:error, error as a string or list of errors}`

  ## Examples
      iex> MyApp.CRUD.delete(struct)
      or
      iex> MyApp.CRUD.delete(MyApp.MyModule, 1)
  """
  @callback delete(item :: Ecto.Schema.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, List.t()} | {:error, String.t()}
  @callback delete(mod :: Module.t(), id :: Integer.t() | String.t()) ::
              {:ok, Ecto.Schema.t()} | {:error, List.t()} | {:error, String.t()}

  @doc """
  ##### Finds a list of elements from the database by matching part of a string to one of the item's fields in the pattern #####
  Takes in parameters:
    - CRUD.find/2:
      - `mod`: Module
      - `opts`: Map or paramatras key: value separated by commas

  Returns `{:ok, list of structures}`

  ## Examples
      iex> MyApp.CRUD.find(MyApp.MyModule, %{key: "sample"})
      or
      iex> MyApp.CRUD.find(MyApp.MyModule, key: "sample")
  """
  @callback find(mod :: Module.t(), opts :: List.t() | Map.t()) :: {:ok, List.t()}
end
