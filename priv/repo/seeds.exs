# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Perseus.Repo.insert!(%Perseus.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Perseus.Repo.insert!(%Perseus.Accounts.User{
  first_name: "John",
  last_name: "Doe",
  email: "jdoe@example.com",
  verified: false
})
