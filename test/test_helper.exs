# Mix.Task.run("ecto.create", ~w(-r ActiveStorage.Test.Repo))
# Mix.Task.run("ecto.migrate", ~w(-r ActiveStorage.Test.Repo))

ActiveStorage.Test.Repo.start_link()

ExUnit.start()
