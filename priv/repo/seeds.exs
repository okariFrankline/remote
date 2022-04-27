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
alias Remote.Accounts.User

alias Remote.Repo

require Logger

now = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

Logger.info("Seeding 1_000_000 users to the database 😅 ...", ansi_color: :green)

1..1_000_000
|> Stream.map(fn _ -> %{points: 0, updated_at: now, inserted_at: now} end)
|> Stream.chunk_every(10_000)
|> Task.async_stream(
  fn chunk ->
    {count, _} = Repo.insert_all(User, chunk, [])
  end,
  ordered: false
)
|> Stream.run()

Logger.info("Seeding complete 🥳", ansi_color: :green)
