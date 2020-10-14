defmodule CRUD do
  use Ecto.Schema

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      import Ecto.Query, only: [from: 2, where: 2, where: 3, offset: 2]
      @cont Keyword.get(opts, :context)

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
        {:ok,
         @cont.all(from(i in mod, select: i, order_by: i.id, limit: ^limit, offset: ^offset))}
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
end
