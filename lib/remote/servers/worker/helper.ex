defmodule Remote.Servers.Worker.Helper do
  @moduledoc """
  Exports all functions required to work with the Worker Server
  """

  alias Remote.Accounts.User

  alias Remote.Repo

  alias Remote.Servers.Worker

  alias User.Query, as: UserQuery

  alias Postgrex.Result

  @typep users :: list(User.t()) | []

  @typep fetch_response :: %{users: users(), timestamp: Worker.timestamp()}

  @run_every Application.compile_env(:remote, [Worker, :run_every])

  @doc """
  Schedules the next time for the worker to run
  """
  @spec do_schedule_next_update(worker_state) :: worker_state when worker_state: Worker.t()
  def do_schedule_next_update(%Worker{} = state) do
    {:ok, _ref} = schedule_next_run()

    state
  end

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
      {:ok, timestamp} <- generate_new_timestamp(),
      {:ok, response} <- build_user_response(users, prev_timestamp),
      {:ok, new_state} <- build_new_state_from_fetch(state, timestamp),
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

  defp build_user_response(users, timestamp) do
    {:ok, %{users: users, timestamp: timestamp}}
  end

  defp build_new_state_from_fetch(state, new_timestamp) do
    {:ok, %{state | timestamp: new_timestamp}}
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
    with(
      {:ok, %Result{command: :update}} <- do_update_all_users(),
      {:ok, new_max_number} <- generate_new_max_number(),
      {:ok, new_state} <- build_new_state_from_update(state, new_max_number),
      {:ok, _ref} <- schedule_next_run()
    ) do
      new_state
    end
  end

  defp do_update_all_users do
    Repo.query("UPDATE users SET points = floor(random()*(100-1+1))+1, updated_at = now()")
  end

  defp generate_new_max_number do
    {:ok, Enum.random(1..100)}
  end

  defp build_new_state_from_update(%Worker{} = state, new_max_number) do
    {:ok, %{state | max_number: new_max_number}}
  end
end
