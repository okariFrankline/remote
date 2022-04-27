defmodule Remote.Servers.Worker do
  @moduledoc """
  This is a GenServer that is responsible for:

  1. Running every 1 minute the update all the records
  2. Exposing a client function to query for users

  """

  use GenServer, shutdown: 5000, restart: :permanent

  defstruct ~w(max_number timestamp)a

  alias __MODULE__.Helper

  @type timestamp :: DateTime.t()

  @type max_number :: pos_integer()

  @type t :: %__MODULE__{timestamp: timestamp(), max_number: max_number()}

  @doc false
  @spec start_link(opts :: Keyword.t()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], name: opts[:name])
  end

  @doc """
  It returns 2 users whose points are greater than the max number
  currently stored within Worker state and the previous timestamp
  """
  @spec fetch_users() :: {:ok, %{users: list(User.t()) | [], timestamp: DateTime.t()}}
  def fetch_users do
    GenServer.call(__MODULE__, :fetch_users)
  end

  @impl GenServer
  def init(_state) do
    {:ok, __MODULE__.new(), {:continue, :update_users}}
  end

  @impl GenServer
  def handle_continue(:update_users, state) do
    {:noreply, Helper.do_update_users(state)}
  end

  @impl GenServer
  def handle_call(:fetch_users, _from, state) do
    {response, new_state} = Helper.do_fetch_users(state)

    {:reply, {:ok, response}, new_state}
  end

  @impl GenServer
  def handle_info(:update_users, state) do
    {:noreply, Helper.do_update_users(state)}
  end

  def new, do: %__MODULE__{max_number: 0, timestamp: nil}
end
