defmodule Remote.Support.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Remote.Repo

  alias Remote.Accounts.User

  @doc false
  def user_factory do
    %User{
      points: Enum.random(1..100)
    }
  end
end
