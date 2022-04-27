defmodule Remote.Accounts.UserTest do
  @moduledoc false

  use Remote.DataCase, async: true

  alias Remote.Accounts.User

  @moduletag :user_schema

  @expected_fields_with_types [
    {:id, :binary_id},
    {:updated_at, :naive_datetime},
    {:inserted_at, :naive_datetime},
    {:points, :integer}
  ]

  @required_fields ~w(points)a

  describe "User Schema Structure: " do
    test "ensures that if the user schema file changes, this test fails of not updated" do
      actual_field_with_types =
        for field <- User.__schema__(:fields) do
          type = User.__schema__(:type, field)

          {field, type}
        end

      assert MapSet.new(@expected_fields_with_types) == MapSet.new(actual_field_with_types)
    end
  end

  describe "User.changeset/2: " do
    setup [:get_user_params]

    test "given the correct params, it always returns a valid changeset", %{
      user_params: %{"points" => points} = params
    } do
      assert %Changeset{valid?: true, changes: %{points: ^points}} = User.changeset(params)
    end

    test "given points that is greater than 100, it returns an invalid changeset" do
      assert %Changeset{valid?: false} = User.changeset(%{"points" => 200})
    end

    test "given points that is less than 0, it returns an invalid changeset" do
      assert %Changeset{valid?: false} = User.changeset(%{"points" => -200})
    end
  end

  defp get_user_params(_context) do
    {:ok, user_params: string_params_for(:user)}
  end
end
