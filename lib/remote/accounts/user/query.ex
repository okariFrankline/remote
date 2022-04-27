defmodule Remote.Accounts.User.Query do
  @moduledoc """
  Exports query functions to be used by the User Queryable
  """

  import Ecto.Query, except: [limit: 3]

  alias Remote.Accounts.User

  @typep ecto_query :: Ecto.Queryable.t()

  @doc false
  def base_query, do: User

  @doc """
  Returns a user query, where the points are more than the
  given number
  """
  @spec with_points_greater_than(query :: ecto_query(), points :: pos_integer()) :: ecto_query()
  def with_points_greater_than(query \\ base_query(), points) do
    where(query, [u], u.points > ^points)
  end

  @doc """
  Returns a user query where the result set is limited to the
  provided number
  """
  @spec limit(query :: ecto_query(), number :: pos_integer()) :: ecto_query()
  def limit(query \\ base_query(), number) do
    Ecto.Query.limit(query, [_u], ^number)
  end
end
