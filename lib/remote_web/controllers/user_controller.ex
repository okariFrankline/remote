defmodule RemoteWeb.UserController do
  @moduledoc false

  use RemoteWeb, :controller

  alias Remote.Accounts

  @doc false
  def fetch_users(%Plug.Conn{} = conn, _params) do
    with {:ok, response} <- Accounts.fetch_users() do
      conn
      |> put_status(200)
      |> render("users.json", response)
    end
  end
end
