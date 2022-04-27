defmodule RemoteWeb.UserControllerTest do
  @moduledoc false

  use RemoteWeb.ConnCase, async: false

  @moduletag :user_controller

  describe "UserController.fetch_users/1: " do
    setup [:insert_users]

    test "If there are users with points more than the max number of the Worker GenServer, it returns a 200 response",
         %{conn: conn} do
      assert conn
             |> get(Routes.user_path(conn, :fetch_users))
             |> json_response(200)
    end
  end

  defp insert_users(_context) do
    {:ok, users: insert_list(50, :user)}
  end
end
