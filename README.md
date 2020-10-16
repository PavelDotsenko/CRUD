# CRUD

A module for easy access to the database.

### Latest release v1.0.1 on 2020-10-16

# How to add to the project
Add this to your dependencies in your mix.exs:
```Elixir
def application do
    [applications: [
        # ... whatever else
        :crud # <-- add this for Elixir <= 1.6
    ]]
end

defp deps do
    [
        # ... whatever else
        { :crud, ">=1.0.1" }, # <-- and this
    ]
end
```

In the `/lib` folder, create a `crud.ex` file with the following contents:
```Elixir
defmodule MyApp.CRUD do
    use CRUD, context: MyApp.MyRepo
end
```

# How to use
More comprehensive information on each function can be obtained from the Elixir console

### Add structure:
```Elixir
$ iex -S mix
iex> {:ok, struct} = MyApp.CRUD.add(MyApp.MyModule, %{key1: val1, key2: val2})
or
iex> {:ok, struct} = MyApp.CRUD.add(MyApp.MyModule, key1: val1, key2: val2)
```

### Get structure:
```Elixir
iex> {:ok, struct} = MyApp.CRUD.get(MyApp.MyModule, 1)
or
iex> {:ok, struct} = MyApp.CRUD.get(MyApp.MyModule, id: 1)
```

### Get all structures:
```Elixir
iex> {:ok, list_of_structures} = MyApp.CRUD.get_all(MyApp.MyModule)
or
iex> {:ok, list_of_structures} = MyApp.CRUD.get_all(MyApp.MyModule, 200)
or
iex> {:ok, list_of_structures} = MyApp.CRUD.get_all(MyApp.MyModule, key: value)
or
iex> {:ok, list_of_structures} = MyApp.CRUD.get_all(MyApp.MyModule, 200, 50)
or
iex> {:ok, list_of_structures} = MyApp.CRUD.get_all(MyApp.MyModule, 200, status: 1)
or
iex> {:ok, list_of_structures} = MyApp.CRUD.get_all(MyApp.MyModule, 200, 50, status: 1)
```

### Changes the structure:
```Elixir
iex> {:ok, struct} = MyApp.CRUD.update(struct, key1: value1, key2: value)
or
iex> {:ok, struct} = MyApp.CRUD.update(MyApp.MyModule, 5, key1: value1, key2: value)
or
iex> {:ok, struct} = MyApp.CRUD.update(MyApp.MyModule, :id, 5, key1: value1, key2: value)
```

### Finds a list of structures:
```Elixir
iex> {:ok, struct} = MyApp.CRUD.find(MyApp.MyModule, key: "sample")
or
iex> {:ok, struct} = MyApp.CRUD.find(MyApp.MyModule, key1: "sample1", key2: "sample2")
```

### Removes a structure:
```Elixir
iex> {:ok, struct} = MyApp.CRUD.delete(struct)
or
iex> {:ok, struct} = MyApp.CRUD.delete(MyApp.MyModule, 1)
```

