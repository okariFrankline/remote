defmodule RemoteWeb.UserView do
  @moduledoc false

  use RemoteWeb, :view

  alias Remote.Accounts.User

  @doc false
  def render("users.json", %{users: users, timestamp: timestamp}) do
    %{
      timestamp: datetime_to_string(timestamp),
      users: render_many(users, __MODULE__, "user.json", as: :user)
    }
  end

  def render("user.json", %{user: %User{points: points, id: user_id}}) do
    %{
      points: points,
      id: user_id
    }
  end

  defp datetime_to_string(%DateTime{} = datetime) do
    DateTime.to_iso8601(datetime)
  end

  defp datetime_to_string(nil), do: nil
end
