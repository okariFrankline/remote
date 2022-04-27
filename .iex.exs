alias Remote.Accounts.User

alias Remote.Servers.Worker

alias Remote.Repo

defmodule Helpers do
  @moduledoc """
  Exports all functions required to work with the Worker Server
  """

  import Ecto.Query, only: [where: 3]

  alias Remote.Accounts.User

  alias Remote.Repo

  alias Remote.Servers.Worker

  alias User.Query, as: UserQuery

  @typep users :: list(User.t()) | []

  @typep timestamp :: DateTime.t()

  @typep fetch_response :: %{users: users(), timestamp: timestamp()}

  @run_every :timer.seconds(60)

  @doc """
  Given the current worker state, it returns a tuple that contains:
  1. The new state of the worker GenServer
  2. A map containing the two users whose points are more that two points and
        the timestamp

  ## Examples
        iex> do_fetch_users(%Worker{})
        {%{users: [%User{}], %Worker{}}}

  """
  @spec do_fetch_users(worker_state :: Worker.t()) ::
          {response :: fetch_response(), new_worker_state :: Worker.t()}
  def do_fetch_users(%Worker{timestamp: prev_timestamp, max_number: max_number} = state) do
    with(
      {:ok, users} <- get_users_from_db(max_number),
      {:ok, new_max_num} <- generate_new_max_number(),
      {:ok, response} <- build_user_response(users, prev_timestamp),
      {:ok, new_state} <- build_new_state(state, new_max_num),
      {:ok, _ref} <- schedule_next_run()
    ) do
      {response, new_state}
    end
  end

  defp get_users_from_db(max_number) do
    users =
      max_number
      |> UserQuery.with_points_greater_than()
      |> UserQuery.limit(2)
      |> Repo.all()

    {:ok, users}
  end

  defp generate_new_timestamp do
    {:ok, DateTime.utc_now()}
  end

  defp generate_new_max_number do
    {:ok, Enum.random(1..100)}
  end

  defp build_user_response(users, timestamp) do
    {:ok, %{users: users, timestamp: timestamp}}
  end

  defp build_new_state(state, new_max_number) do
    {:ok, %{state | max_number: new_max_number}}
  end

  defp schedule_next_run do
    ref = Process.send_after(self(), :update_users, @run_every)

    {:ok, ref}
  end

  @doc """
  Updates all the user records in the db by setting each of the users'
  records to a random number between 0 and 100

  """
  @spec do_update_users(worker_state :: Worker.t()) :: new_worker_state :: Worker.t()
  def do_update_users(%Worker{} = state) do
    with {:ok, 1_000_000} <- do_update_all_users(),
         {:ok, timestamp} <- generate_new_timestamp(),
         {:ok, new_state} <- build_new_state_from_update(state, timestamp) do
      new_state
    end
  end

  defp do_update_all_users do
    %Postgrex.Result{num_rows: count} =
      Repo.query("UPDATE users SET points = floor(random()*(100-1+1))+1 update_at = $1", [now()])

    {:ok, count}
  end

  defp now do
    NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
  end

  defp do_update_user(user) do
    {:ok, points} = generate_new_max_number()

    user
    |> User.changeset(%{points: points})
    |> Repo.update()
  end

  defp build_new_state_from_update(%Worker{} = state, new_timestamp) do
    {:ok, %{state | timestamp: new_timestamp}}
  end
end

fun = fn -> Helpers.do_update_users(%Worker{}) end

users = fn ->
  now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

  1..1_000_000
  |> Stream.map(fn _ -> %{points: 0, updated_at: now, inserted_at: now} end)
  |> Stream.chunk_every(10_000)
  |> Task.async_stream(
    fn chunk ->
      {count, _} = Repo.insert_all(User, chunk, [])
    end,
    ordered: false
  )
  |> Stream.run()

  IO.puts("Inserted 1000000 users")
end
