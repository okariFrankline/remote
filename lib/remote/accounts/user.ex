defmodule Remote.Accounts.User do
  @moduledoc """
  Defines struct representing a user
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :points, :integer, default: 0

    timestamps()
  end

  @doc """
  Called during the creation and update of a user's points
  """
  @spec changeset(user :: t(), attrs :: map()) :: Changeset.t()
  def changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> cast(attrs, [:points])
    |> validate_required([:points])
    |> validate_number(:points, greater_than_or_equal_to: 0, less_than_or_equal_to: 100)
  end
end
