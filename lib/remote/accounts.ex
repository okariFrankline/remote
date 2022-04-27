defmodule Remote.Accounts do
  @moduledoc """
  The Accounts context.
  """

  alias Remote.Servers.Worker

  @doc """
  Returns at least two users from the db through the Worker
  GenServer
  """
  defdelegate fetch_users, to: Worker, as: :fetch_users
end
