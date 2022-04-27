defmodule RemoteWeb.UserController do
  @moduledoc false

  use RemoteWeb, :controller

  alias Remote.Accounts

  @doc false
  def fetch_users(%Plug.Conn{} = conn, _params) do
    with {:ok, response} <- Accounts.fetch_users() do
      conn
      |> put_status(200)
      |> put_resp_header("content-type", "application/json")
      |> render("users.json", response)
    end
  end
end
