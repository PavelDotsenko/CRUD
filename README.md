# CRUD

A module for easy access to the database.

## How to initiate
- Rename MyApp to your project name
- Rename MyRepo to the name of your module for working with the database

## How to use
### Get:
- MyApp.CRUD.get(MyApp.MyModule, id) (where id is the element identifier in the database)
- MyApp.CRUD.get(MyApp.MyModule, id: 1) (searches for a match by key and its value)
- MyApp.CRUD.get(MyApp.MyModule, %{id: 1}) (the same, but with a different format for specifying data to change)
- MyApp.CRUD.get_all(MyApp.MyModule)
- MyApp.CRUD.get_all(MyApp.MyModule, status: 1)
- MyApp.CRUD.get_all(MyApp.MyModule, %{status: 1})

### Update:
- MyApp.CRUD.update(item, %{status: 1}) (item - pre-received structure, %{status: 1} - data to change)
- MyApp.CRUD.update(item, status: 1) (the same, but with a different format for specifying data to change)
- MyApp.CRUD.update(MyApp.MyModule, id, status: 1) (where id is the element identifier in the database)
- MyApp.CRUD.update(MyApp.MyModule, id, %{status: 1})
- MyApp.CRUD.update(MyApp.MyModule, :key, value, status: 1)
- MyApp.CRUD.update(MyApp.MyModule, :key, value, %{status: 1})

### Delete:
- MyApp.CRUD.delete(item)
- MyApp.CRUD.delete(MyApp.MyModule, id)

### Add:
- MyApp.CRUD.add(MyApp.MyModule, status: 1)
- MyApp.CRUD.add(MyApp.MyModule, %{status: 1})
