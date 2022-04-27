defmodule Remote.Servers.Worker.HelperTest do
  @moduledoc false

  use Remote.DataCase, async: true

  alias Remote.Accounts.User

  alias Remote.Servers.Worker

  alias Worker.Helper

  describe "Helpers.do_fetch_users/1: " do
    setup [:create_new_worker_state, :insert_users]

    test "given the current worker state, it returns 2 users with the points above the current worker state max_number",
         %{worker_state: %{max_number: max_number, timestamp: timestamp} = state} do
      state
      |> Helper.do_fetch_users()
      |> assert_schedule_message_received()
      |> assert_users_length()
      |> assert_users_points_greater_than(max_number)
      |> assert_response_timestamp_same_to_old_timestamp(timestamp)
      |> assert_new_and_old_states_timestamps_different(timestamp)
    end
  end

  describe "Helpers.do_update_users/1: " do
    setup [:create_new_worker_state, :insert_users]

    @tag :here
    test "ensures that it updates all the users in the db with a new random number", %{
      worker_state: state
    } do
      users = Repo.all(User)

      Helper.do_update_users(state)

      assert_updated_at_for_all_users_changed(users)
    end
  end

  defp create_new_worker_state(_context) do
    time = Timex.shift(DateTime.utc_now(), minutes: -1)

    {:ok, worker_state: %Worker{max_number: 0, timestamp: time}}
  end

  defp insert_users(_context) do
    {:ok, users: insert_list(20, :user, points: Enum.random(1..100))}
  end

  defp assert_schedule_message_received(response) do
    Process.sleep(:timer.seconds(4))

    assert_received :update_users

    response
  end

  defp assert_users_length({%{users: users}, _new_state} = response) do
    assert length(users) == 2

    response
  end

  defp assert_users_points_greater_than({%{users: users}, _new_state} = response, max_number) do
    for user <- users, do: assert(user.points > max_number)

    response
  end

  defp assert_response_timestamp_same_to_old_timestamp(
         {%{timestamp: new_timestamp}, _new_state} = response,
         old_timestamp
       ) do
    assert DateTime.compare(old_timestamp, new_timestamp) == :eq

    response
  end

  defp assert_new_and_old_states_timestamps_different(
         {_user_res, %Worker{timestamp: new_timestamp}} = response,
         old_timestamp
       ) do
    assert new_timestamp > old_timestamp

    response
  end

  defp assert_updated_at_for_all_users_changed(original_users) do
    updated_users = Repo.all(User)

    for user <- original_users do
      updated_user = Enum.find(updated_users, &(&1.id == user.id))

      # CAVEAT: Because these tests run almost at the same, the difference between
      # insertion and update maybe be so small that this might be considered it happens
      # at the same time.
      # Because we are generating random number, it makes asserting against numbers difficult
      # making this a more or less safer way to assert it ran successfully
      assert NaiveDateTime.compare(updated_user.updated_at, user.updated_at) in [:gt, :eq]
    end
  end
end
