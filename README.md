# Remote

This is a simple Restful application that exposes a single endpoint to get the user points and
last time the api was called

# Installation and Setup

## Elixir and OTP Versions

Installation can be done using [asdf](https://asdf-vm.com)

1. **Elixir v1.13.3**
2. **Erlang v24.3**

## Phoenix

The application uses the latest version of**Phoenix v1.6.6** which can be installed from the [documentations](https://hexdocs.pm/phoenix/installation.html#phoenix)

## Postgres

The application uses the latest version of PostgreSQL. However, any version above **v9** will also work fine

# Running the application

After successful cloning of the application run the commands below from your terminal

cd into the project

```
cd remote/
```

Get all the dependencies

```
mix do deps.get, compile
```

Run the tests:

```
mix test
```

Setup the database by running:

```
mix ecto.setup
```

Start the application using:

```
mix phx.server
```

Open your browser and go to:

```
localhost:4000/
```

Visiting this should returns a response similar to this

```json
{
  "timestamp": "2022-04-27T17:54:21.105699Z",
  "users": [
    {
      "id": "955be656-b13b-4caa-b4b6-fcf726f375c8",
      "points": 88
    },
    {
      "id": "e27ef9d0-368f-4def-9eac-c5f7e50940a1",
      "points": 86
    }
  ]
}
```
