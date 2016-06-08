ExUnit.start

Mix.Task.run "ecto.create", ~w(-r Mobbur.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r Mobbur.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(Mobbur.Repo)

