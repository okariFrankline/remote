# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Remote.Repo.insert!(%Remote.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# alias Remote.Accounts.User

# 1..1_000_000
# |> Stream.map(fn _ -> %{points: 0} end)
# |> Stream.chunk_every(50_000)
# |> Stream.each(fn list ->
#   Repo.insert_all(User, list, [])
# end)
# |> Stream.run()
