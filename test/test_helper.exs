Mix.Task.run("ecto.create", ~w(-r ExActiveStorage.Repo))
Mix.Task.run("ecto.migrate", ~w(-r ExActiveStorage.Repo))

ExActiveStorage.Repo.start_link()

ExUnit.start()
